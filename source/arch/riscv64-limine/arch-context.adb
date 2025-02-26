------------------------------------------------------------------
--  arch-context.adb: Architecture-specific context switching.
--  (RISC-V 64-bit version)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
------------------------------------------------------------------
pragma SPARK_Mode (On);
with System;           use System;
with Interfaces;       use Interfaces;
with System.Machine_Code;
with Arch.CPU;         use Arch.CPU;
with Arch.Interrupts;  use Arch.Interrupts;

package body Arch.Context is
   pragma Warnings (Off, "SPARK_Mode is enabled");

   ----------------------------------------------------------------------------
   --  Package-Level Constant for misa
   ----------------------------------------------------------------------------
   -- Read misa once at elaboration time. Since misa is immutable during runtime,
   -- this value is safe to reuse for all extension checks.
   MISA_Value : constant Unsigned_64 := Get_CSR(16#301#);

   ----------------------------------------------------------------------------
   --  Internal General-Purpose Context Record (64-bit)
   ----------------------------------------------------------------------------
   type GP_Context_Type is record
      SP      : Unsigned_64;
      SEPC    : Unsigned_64;
      SSTATUS : Unsigned_64;
      A0      : Unsigned_64;
   end record;

   ----------------------------------------------------------------------------
   --  Conversion Functions
   --  (Converts between our 64-bit internal context and the external GP_Context,
   --   defined in Arch.Interrupts as a 32-bit record.)
   ----------------------------------------------------------------------------
   function To_GP_Context_Type(Frame : GP_Context) return GP_Context_Type is
   begin
      return (
         SP      => Unsigned_64(Frame.R2),         -- x2: Stack Pointer
         SEPC    => Get_CSR(16#141#),              -- SEPC CSR (0x141)
         SSTATUS => Get_CSR(16#100#),              -- SSTATUS CSR (0x100)
         A0      => Unsigned_64(Frame.R10)           -- x10: Return value (e.g., fork)
      );
   end To_GP_Context_Type;

   function To_Frame(Ctx : GP_Context_Type) return GP_Context is
   begin
      return (
         R2  => Unsigned_32(Ctx.SP and 16#FFFFFFFF#),
         R10 => Unsigned_32(Ctx.A0 and 16#FFFFFFFF#),
         others => 0
      );
   end To_Frame;

   ----------------------------------------------------------------------------
   --  CSR Access and Extension Detection
   ----------------------------------------------------------------------------
   function Get_CSR(CSR_Number : Unsigned_64) return Unsigned_64 is
      Value : Unsigned_64;
   begin
      Asm("csrr %0, %1",
          Outputs  => Unsigned_64'Asm_Output("=r", Value),
          Inputs   => Unsigned_64'Asm_Input("i", CSR_Number),
          Volatile => True);
      pragma Assert(Value /= 0, "CSR must return a non-zero value");
      return Value;
   end Get_CSR;

   -- Return the current hart ID from the mhartid CSR.
   function Get_Hart_ID return Unsigned_64 is
      Hart : Unsigned_64;
   begin
      Asm("csrr %0, mhartid",
          Outputs  => Unsigned_64'Asm_Output("=r", Hart),
          Volatile => True);
      return Hart;
   end Get_Hart_ID;

   -- Uses the stored MISA_Value to check for a specific extension.
   function Has_Extension(Feature_Bit : Unsigned_64) return Boolean is
   begin
      return (MISA_Value and Feature_Bit) /= 0;
   end Has_Extension;

   -- Constants for FP Extensions.
   F_Extension_Bit : constant Unsigned_64 := 16#20#;  -- F extension (bit 5)
   D_Extension_Bit : constant Unsigned_64 := 16#40#;  -- D extension (bit 6)
   Q_Extension_Bit : constant Unsigned_64 := 16#80#;  -- Q extension (bit 7, if implemented)

   ----------------------------------------------------------------------------
   --  General-Purpose Context Switching Routines
   ----------------------------------------------------------------------------
   procedure Init_GP_Context
      (Ctx        : out GP_Context;
       Stack      : System.Address;
       Start_Addr : System.Address) is
      Ctx_Impl : GP_Context_Type;
      Current_Hart : Unsigned_64 := Get_Hart_ID;
      Stack_Int : Integer := To_Integer(Stack);
      Start_Int : Integer := To_Integer(Start_Addr);
   begin
      pragma Assume(Stack /= System.Null_Address and Start_Addr /= System.Null_Address);
      pragma Assert(Stack_Int mod 16 = 0, "Stack address must be 16-byte aligned");
      Ctx_Impl.SP       := Unsigned_64(Stack_Int);
      Ctx_Impl.SEPC     := Unsigned_64(Start_Int);
      Ctx_Impl.SSTATUS  := Get_CSR(16#100#);  -- SSTATUS CSR
      Ctx_Impl.A0       := 0;
      Ctx := To_Frame(Ctx_Impl);
      pragma Assert(Ctx.R2 = Unsigned_32(Stack_Int and 16#FFFFFFFF#),
                    "Stack pointer correctly set");
      -- Optionally, update per-core local data using Arch.CPU with Current_Hart.
   end Init_GP_Context;

   procedure Load_GP_Context(Ctx : GP_Context) with No_Return is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type(Ctx);
   begin
      Asm("csrw sepc, %0; csrw sstatus, %1; mv sp, %2; sret",
          Inputs   => (Unsigned_64'Asm_Input("r", Ctx_Impl.SEPC),
                       Unsigned_64'Asm_Input("r", Ctx_Impl.SSTATUS),
                       Unsigned_64'Asm_Input("r", Ctx_Impl.SP)),
          Clobber  => "memory",
          Volatile => True);
      loop
         null;
      end loop;
   end Load_GP_Context;

   procedure Success_Fork_Result(Ctx : in out GP_Context) is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type(Ctx);
   begin
      Ctx_Impl.A0 := 0;               -- Child process: fork returns 0 in x10.
      Ctx_Impl.SEPC := Ctx_Impl.SEPC + 4; -- Advance SEPC to skip fork-return.
      Ctx := To_Frame(Ctx_Impl);
      pragma Assert(Ctx.R10 = 0, "Forked process must return zero");
   end Success_Fork_Result;

   procedure Save_Core_Context(Ctx : out Core_Context) is
      Temp : Unsigned_64;
      Current_Hart : Unsigned_64 := Get_Hart_ID;
   begin
      -- For riscv64, no extra core state is needed beyond GP registers.
      Temp := 0;
      Ctx := Temp;
      pragma Assert(Ctx = 0, "Core context saved as zero on riscv64");
      -- Optionally, update Arch.CPU.Core_Locals(Current_Hart) if required.
   end Save_Core_Context;

   ----------------------------------------------------------------------------
   --  Floating-Point Context Routines (Dispatch via Function Pointers)
   ----------------------------------------------------------------------------
   type FP_Save_Routine_Type is access procedure (Ctx : in out FP_Context);
   type FP_Load_Routine_Type is access procedure (Ctx : FP_Context);

   FP_Save_Routine : FP_Save_Routine_Type;
   FP_Load_Routine : FP_Load_Routine_Type;

   -- No-op routines if FP support is absent.
   procedure FP_Save_NoOp(Ctx : in out FP_Context) is
   begin
      null;
   end FP_Save_NoOp;

   procedure FP_Load_NoOp(Ctx : FP_Context) is
   begin
      null;
   end FP_Load_NoOp;

   -- Single-Precision FP routines (for F extension only; 4 bytes per register).
   procedure Save_FP_Context_F(Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      for Reg in 0 .. 31 loop
         Asm("fsw f" & Reg'Image & ", " & (Reg * 4)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
      for Offset in 128 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_F;

   procedure Load_FP_Context_F(Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      for Reg in 0 .. 31 loop
         Asm("flw f" & Reg'Image & ", " & (Reg * 4)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
   end Load_FP_Context_F;

   -- Double-Precision FP routines (if D extension is available; 8 bytes per register).
   procedure Save_FP_Context_D(Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      for Reg in 0 .. 31 loop
         Asm("fsd f" & Reg'Image & ", " & (Reg * 8)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
      for Offset in 256 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_D;

   procedure Load_FP_Context_D(Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      for Reg in 0 .. 31 loop
         Asm("fld f" & Reg'Image & ", " & (Reg * 8)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
   end Load_FP_Context_D;

   ----------------------------------------------------------------------------
   --  Setup FP Routines (Dispatch Based on Detected FP Extensions)
   ----------------------------------------------------------------------------
   procedure Setup_FP_Routines is
   begin
      if (MISA_Value and F_Extension_Bit) /= 0 then
         if (MISA_Value and D_Extension_Bit) /= 0 then
            FP_Save_Routine := FP_Save_Routine_Type'(Save_FP_Context_D'Access);
            FP_Load_Routine := FP_Load_Routine_Type'(Load_FP_Context_D'Access);
         else
            FP_Save_Routine := FP_Save_Routine_Type'(Save_FP_Context_F'Access);
            FP_Load_Routine := FP_Load_Routine_Type'(Load_FP_Context_F'Access);
         end if;
      else
         FP_Save_Routine := FP_Save_Routine_Type'(FP_Save_NoOp'Access);
         FP_Load_Routine := FP_Load_Routine_Type'(FP_Load_NoOp'Access);
      end if;
   end Setup_FP_Routines;

   ----------------------------------------------------------------------------
   --  Public Floating-Point Context Routines
   ----------------------------------------------------------------------------
   procedure Init_FP_Context(Ctx : out FP_Context) is
   begin
      Ctx := (others => 0);
      pragma Assert(for all I in FP_Context'Range => Ctx(I) = 0,
                    "FP context must be zeroed at init");
      Setup_FP_Routines;
      FP_Save_Routine.all(Ctx);
   end Init_FP_Context;

   procedure Save_FP_Context(Ctx : in out FP_Context) is
   begin
      FP_Save_Routine.all(Ctx);
   end Save_FP_Context;

   procedure Load_FP_Context(Ctx : FP_Context) is
   begin
      FP_Load_Routine.all(Ctx);
   end Load_FP_Context;

   procedure Destroy_FP_Context(Ctx : in out FP_Context) is
   begin
      Ctx := (others => 0);
      pragma Assert(for all I in FP_Context'Range => Ctx(I) = 0,
                    "FP context successfully destroyed");
   end Destroy_FP_Context;

end Arch.Context;
