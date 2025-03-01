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
pragma Warnings (Off, "SPARK_Mode is enabled");

with System;           use System;
with Interfaces;       use Interfaces;
with System.Machine_Code;
with Arch.CPU;         use Arch.CPU;
with Arch.Interrupts;  use Arch.Interrupts;

package body Arch.Context is

   --Package Variables, Constants, and Types
   ------------------------------------------
   type GP_Context_Type is record
      SP      : Unsigned_64;
      SEPC    : Unsigned_64;
      SSTATUS : Unsigned_64;
      A0      : Unsigned_64;
   end record;

   MISA_Value : constant Unsigned_64 := Get_CSR(16#301#);

   F_Extension_Bit : constant Unsigned_64 := 16#20#;  -- F extension (bit 5)
   D_Extension_Bit : constant Unsigned_64 := 16#40#;  -- D extension (bit 6)
   Q_Extension_Bit : constant Unsigned_64 := 16#80#;  -- Q extension (bit 7, if implemented)

   type FP_Save_Routine_Type is access procedure (Ctx : in out FP_Context);
   type FP_Load_Routine_Type is access procedure (Ctx : FP_Context);

   FP_Save_Routine : FP_Save_Routine_Type;
   FP_Load_Routine : FP_Load_Routine_Type;

   -- Public Sectiom
   ------------------------------------------

   -- Initialize the general-purpose context
   procedure Init_GP_Context
      (Ctx        : out GP_Context;
       Stack      : System.Address;
       Start_Addr : System.Address) is
      Ctx_Impl     : GP_Context_Type;
      Current_Hart : Unsigned_64 := Get_Hart_ID;
      Stack_Int    : Integer := To_Integer(Stack);
      Start_Int    : Integer := To_Integer(Start_Addr);
   begin
      pragma Assume(Stack /= System.Null_Address and Start_Addr /= System.Null_Address);
      pragma Assert(Stack_Int mod 16 = 0, "Stack address must be 16-byte aligned");
      pragma Assert(Start_Int /= 0, "Start address must be nonzero");
      Ctx_Impl.SP       := Unsigned_64(Stack_Int);
      Ctx_Impl.SEPC     := Unsigned_64(Start_Int);
      Ctx_Impl.SSTATUS  := Get_CSR(16#100#);
      Ctx_Impl.A0       := 0;
      Ctx := To_Frame(Ctx_Impl);
      pragma Assert(Ctx.R2 = Unsigned_32(Stack_Int and 16#FFFFFFFF#), "Stack pointer correctly set");
      pragma Assert(Ctx.R10 = 0, "Initial fork return value must be zero");
   end Init_GP_Context;

   -- Load the general-purpose context
   procedure Load_GP_Context(Ctx : GP_Context) with No_Return is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type(Ctx);
   begin
      pragma Assert(Ctx_Impl.SP /= 0, "SP must not be zero");
      pragma Assert(Ctx_Impl.SEPC /= 0, "SEPC must not be zero");
      pragma Assert(Ctx_Impl.SSTATUS /= 0, "SSTATUS must not be zero");
      Asm("csrw sepc, %0; csrw sstatus, %1; mv sp, %2; sret",
          Inputs   => (Unsigned_64'Asm_Input("r", Ctx_Impl.SEPC),
                       Unsigned_64'Asm_Input("r", Ctx_Impl.SSTATUS),
                       Unsigned_64'Asm_Input("r", Ctx_Impl.SP)),
          Clobber  => "memory",
          Volatile => True);
      loop null; end loop;
   end Load_GP_Context;

   -- Show that the forked process has returned successfully
   procedure Success_Fork_Result(Ctx : in out GP_Context) is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type(Ctx);
      Old_SEPC : Unsigned_64 := Ctx_Impl.SEPC;
   begin
      Ctx_Impl.A0 := 0;
      Ctx_Impl.SEPC := Ctx_Impl.SEPC + 4;  -- Advance by 4 bytes (size of one instruction)
      Ctx := To_Frame(Ctx_Impl);
      pragma Assert(Ctx.R10 = 0, "Forked process must return zero");
      pragma Assert(Ctx_Impl.SEPC > Old_SEPC, "SEPC should have advanced");
   end Success_Fork_Result;

   -- Save the Core Context
   procedure Save_Core_Context(Ctx : out Core_Context) is
      Current_Hart : constant Unsigned_64 := Get_Hart_ID;
      -- Map the current hart ID (assumed to start at 0) to a 1-based index in Core_Locals.
      Core_Index   : constant Positive := Positive(Integer(Current_Hart) + 1);
   begin
      pragma Assert(Core_Index <= Core_Count, "Core index out of bounds");
      -- Save the entire per-core state (User_Stack, Kernel_Stack, Hart_ID, etc.) from Core_Locals.
      Ctx := Core_Locals(Core_Index);
      pragma Assert(Ctx.Hart_ID = Current_Hart, "Saved core context must have the current hart ID");
      pragma Assert(Ctx.Number = Core_Index, "Saved core context must have the correct core number");
   end Save_Core_Context;

   -- Initialize the floating-point context
   procedure Init_FP_Context(Ctx : out FP_Context) is
   begin
      Ctx := (others => 0);
      pragma Assert(for all I in FP_Context'Range => Ctx(I) = 0,
                    "FP context must be zeroed at init");
      Setup_FP_Routines;
      FP_Save_Routine.all(Ctx);
      pragma Assert(for all I in FP_Context'Range => Ctx(I) = 0, "FP context should remain zero after Init_FP_Context");
   end Init_FP_Context;

   -- Save the floating-point context
   procedure Save_FP_Context(Ctx : in out FP_Context) is
   begin
      FP_Save_Routine.all(Ctx);
   end Save_FP_Context;

   -- Load the floating-point context
   procedure Load_FP_Context(Ctx : FP_Context) is
   begin
      FP_Load_Routine.all(Ctx);
   end Load_FP_Context;

   -- Destroy the floating-point context
   procedure Destroy_FP_Context(Ctx : in out FP_Context) is
   begin
      Ctx := (others => 0);
      pragma Assert(for all I in FP_Context'Range => Ctx(I) = 0, "FP context successfully destroyed");
   end Destroy_FP_Context;

   ------------------------------------------
   -- End Public Section

   -- Internal Section
   ------------------------------------------

   -- Convert a GP_Context_Type record to a GP_Context record
   function To_Frame(Ctx : GP_Context_Type) return GP_Context is
      pragma Inline;
   begin
      -- Ensure that only lower 32 bits of SP and A0 are used.
      pragma Assert(Ctx.SP <= 16#FFFFFFFF#, "Internal SP exceeds 32 bits");
      pragma Assert(Ctx.A0 <= 16#FFFFFFFF#, "Internal A0 exceeds 32 bits");
      return (
         R2  => Unsigned_32(Ctx.SP and 16#FFFFFFFF#),
         R10 => Unsigned_32(Ctx.A0 and 16#FFFFFFFF#),
         others => 0
      );
   end To_Frame;

   -- Convert a GP_Context record to a GP_Context_Type record
   function To_GP_Context_Type(Frame : GP_Context) return GP_Context_Type is
      pragma Inline;
   begin
      pragma Assert(Frame.R2 <= 16#FFFFFFFF#, "Frame.R2 invalid");
      pragma Assert(Frame.R10 <= 16#FFFFFFFF#, "Frame.R10 invalid");
      return (
         SP      => Unsigned_64(Frame.R2),
         SEPC    => Get_CSR(16#141#),
         SSTATUS => Get_CSR(16#100#),
         A0      => Unsigned_64(Frame.R10)
      );
   end To_GP_Context_Type;

   -- No-op save and load routines for when the F, D, and Q extensions are not present
   procedure FP_Save_NoOp(Ctx : in out FP_Context) is
   begin
      null;
   end FP_Save_NoOp;

   -- No-op save and load routines for when the F, D, and Q extensions are not present
   procedure FP_Load_NoOp(Ctx : FP_Context) is
   begin
      null;
   end FP_Load_NoOp;

   -- Save the single-precision floating-point registers of the context
   procedure Save_FP_Context_F(Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      pragma Assert(FP_Ptr /= System.Null_Address, "FP context pointer must not be null");
      for Reg in 0 .. 31 loop
         Asm("fsw f" & Reg'Image & ", " & (Reg * 4)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
      for Offset in 128 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_F;

   -- Load the single-precision floating-point registers to the context
   procedure Load_FP_Context_F(Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      pragma Assert(FP_Ptr /= System.Null_Address, "FP context pointer must not be null");
      for Reg in 0 .. 31 loop
         Asm("flw f" & Reg'Image & ", " & (Reg * 4)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
   end Load_FP_Context_F;

   -- Save the double-precision floating-point registers of the context
   procedure Save_FP_Context_D(Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      pragma Assert(FP_Ptr /= System.Null_Address, "FP context pointer must not be null");
      for Reg in 0 .. 31 loop
         Asm("fsd f" & Reg'Image & ", " & (Reg * 8)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
      for Offset in 256 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_D;

   -- Load the double-precision floating-point registers to the context
   procedure Load_FP_Context_D(Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address(Ctx);
   begin
      pragma Assert(FP_Ptr /= System.Null_Address, "FP context pointer must not be null");
      for Reg in 0 .. 31 loop
         Asm("fld f" & Reg'Image & ", " & (Reg * 8)'Image & "(%0)",
             Inputs   => System.Address'Asm_Input("r", FP_Ptr),
             Volatile => True);
      end loop;
   end Load_FP_Context_D;

   -- Set the FP save and load routines based on the MISA register
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
      pragma Assert(FP_Save_Routine /= null and FP_Load_Routine /= null,
                    "FP dispatch routines must be set");
   end Setup_FP_Routines;

   ------------------------------------------
   -- End Internal Section

end Arch.Context;
