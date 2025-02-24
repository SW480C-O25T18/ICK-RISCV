------------------------------------------------------------------
--  arch-context.adb: Architecture-specific context switching.
--  Copyright (C) 2024 streaksu
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
with Arch.Interrupts;
with Arch.CPU;

package body Arch.Context is
   pragma Warnings (Off, "SPARK_Mode is enabled");

   ----------------------------------------------------------------------------
   --  Extension Constants
   ----------------------------------------------------------------------------
   F_Extension_Bit : constant Unsigned_64 := 16#20#;  -- Bit 5: F extension
   D_Extension_Bit : constant Unsigned_64 := 16#40#;  -- Bit 6: D extension

   ----------------------------------------------------------------------------
   --  Function Pointer Types for FP Routines
   ----------------------------------------------------------------------------
   type FP_Save_Routine_Type is access procedure (Ctx : in out FP_Context);
   type FP_Load_Routine_Type is access procedure (Ctx : FP_Context);

   FP_Save_Routine : FP_Save_Routine_Type;
   FP_Load_Routine : FP_Load_Routine_Type;

   ----------------------------------------------------------------------------
   --  No-Op FP Routines (if no FP support)
   ----------------------------------------------------------------------------
   procedure FP_Save_NoOp (Ctx : in out FP_Context) is
   begin
      null;
   end FP_Save_NoOp;

   procedure FP_Load_NoOp (Ctx : FP_Context) is
   begin
      null;
   end FP_Load_NoOp;

   ----------------------------------------------------------------------------
   --  Double-Precision FP Routines (using fsd/fld)
   ----------------------------------------------------------------------------
   procedure Save_FP_Context_D (Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address (Ctx);
   begin
      -- Save registers f0 .. f31 using fsd (8 bytes per register)
      System.Machine_Code.Asm ("fsd f0,   0(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- (Unroll similar calls for registers f1 .. f30)
      System.Machine_Code.Asm ("fsd f31,248(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- Zero any remaining bytes in the FP context buffer.
      for Offset in 256 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_D;

   procedure Load_FP_Context_D (Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address (Ctx);
   begin
      System.Machine_Code.Asm ("fld f0,   0(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- (Unroll similar calls for registers f1 .. f30)
      System.Machine_Code.Asm ("fld f31,248(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
   end Load_FP_Context_D;

   ----------------------------------------------------------------------------
   --  Single-Precision FP Routines (using fsw/flw)
   ----------------------------------------------------------------------------
   procedure Save_FP_Context_F (Ctx : in out FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address (Ctx);
   begin
      -- Save registers f0 .. f31 using fsw (4 bytes per register)
      System.Machine_Code.Asm ("fsw f0,   0(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- (Unroll similar calls for registers f1 .. f30)
      System.Machine_Code.Asm ("fsw f31,124(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- Zero the rest of the FP context area.
      for Offset in 128 .. FP_Context'Length - 1 loop
         Ctx(Offset + 1) := 0;
      end loop;
   end Save_FP_Context_F;

   procedure Load_FP_Context_F (Ctx : FP_Context) is
      FP_Ptr : System.Address := FP_Context'Address (Ctx);
   begin
      System.Machine_Code.Asm ("flw f0,   0(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
      -- (Unroll similar calls for registers f1 .. f30)
      System.Machine_Code.Asm ("flw f31,124(%0)",
         Inputs   => System.Address'Asm_Input ("r", FP_Ptr),
         Volatile => True);
   end Load_FP_Context_F;

   ----------------------------------------------------------------------------
   --  Setup FP Routines at Initialization
   ----------------------------------------------------------------------------
   procedure Setup_FP_Routines is
   begin
      if Has_Extension (F_Extension_Bit) then
         if Has_Extension (D_Extension_Bit) then
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
   --  General-Purpose Context Switching Routines
   ----------------------------------------------------------------------------
   type GP_Context_Type is record
      SP       : Unsigned_64;
      SEPC     : Unsigned_64;
      SSTATUS  : Unsigned_64;
      A0       : Unsigned_64;
   end record;

   function To_GP_Context_Type (Frame : GP_Context) return GP_Context_Type is
   begin
      return (SP       => Unsigned_64 (Frame.R2),
              SEPC     => Get_CSR (16#141#),
              SSTATUS  => Get_CSR (16#100#),
              A0       => Unsigned_64 (Frame.R10));
   end To_GP_Context_Type;

   function To_Frame (Ctx : GP_Context_Type) return GP_Context is
   begin
      return (R2  => Unsigned_32 (Ctx.SP and 16#FFFFFFFF#),
              R10 => Unsigned_32 (Ctx.A0 and 16#FFFFFFFF#),
              others => 0);
   end To_Frame;

   procedure Init_GP_Context
      (Ctx        : out GP_Context;
       Stack      : System.Address;
       Start_Addr : System.Address)
   is
      Ctx_Impl : GP_Context_Type;
   begin
      pragma Assume (Stack /= System.Null_Address and Start_Addr /= System.Null_Address);
      Ctx_Impl.SP       := Unsigned_64 (To_Integer (Stack));
      Ctx_Impl.SEPC     := Unsigned_64 (To_Integer (Start_Addr));
      Ctx_Impl.SSTATUS  := Get_CSR (16#100#);
      Ctx_Impl.A0       := 0;
      Ctx := To_Frame (Ctx_Impl);
      pragma Assert (Ctx.R2 = Unsigned_32 (To_Integer (Stack) and 16#FFFFFFFF#),
                     "Stack pointer correctly set");
   end Init_GP_Context;

   procedure Load_GP_Context (Ctx : GP_Context) with No_Return is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type (Ctx);
   begin
      System.Machine_Code.Asm (
         "csrw sepc, %0; csrw sstatus, %1; mv sp, %2; sret",
         Inputs   => (Unsigned_64'Asm_Input ("r", Ctx_Impl.SEPC),
                      Unsigned_64'Asm_Input ("r", Ctx_Impl.SSTATUS),
                      Unsigned_64'Asm_Input ("r", Ctx_Impl.SP)),
         Clobber  => "memory",
         Volatile => True);
      loop
         null;
      end loop;
   end Load_GP_Context;

   procedure Success_Fork_Result (Ctx : in out GP_Context) is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type (Ctx);
   begin
      Ctx_Impl.A0 := 0;
      Ctx_Impl.SEPC := Ctx_Impl.SEPC + 4;
      Ctx := To_Frame (Ctx_Impl);
      pragma Assert (Ctx.R10 = 0, "Return value must be zero for forked process");
   end Success_Fork_Result;

   ----------------------------------------------------------------------------
   --  Floating-Point Context Routines (Dispatch via function pointers)
   ----------------------------------------------------------------------------
   procedure Init_FP_Context (Ctx : out FP_Context) is
   begin
      -- Always start with a zeroed FP context.
      Ctx := (others => 0);
      pragma Assert (for all I in FP_Context'Range => Ctx(I) = 0,
                     "FP context zeroed");
      -- Set up the FP routine pointers once.
      Setup_FP_Routines;
      -- Save the current FP context using the chosen routine.
      FP_Save_Routine.all (Ctx);
   end Init_FP_Context;

   procedure Save_FP_Context (Ctx : in out FP_Context) is
   begin
      FP_Save_Routine.all (Ctx);
   end Save_FP_Context;

   procedure Load_FP_Context (Ctx : FP_Context) is
   begin
      FP_Load_Routine.all (Ctx);
   end Load_FP_Context;

   procedure Destroy_FP_Context (Ctx : in out FP_Context) is
   begin
      Ctx := (others => 0);
      pragma Assert (for all I in FP_Context'Range => Ctx(I) = 0,
                     "FP context destroyed");
   end Destroy_FP_Context;

   ----------------------------------------------------------------------------
   --  Core Context Routine
   ----------------------------------------------------------------------------
   procedure Save_Core_Context (Ctx : out Core_Context) is
      Temp : Unsigned_64;
   begin
      -- For riscv64, no extra core state needs saving.
      Temp := 0;
      Ctx := Temp;
      pragma Assert (Ctx = 0, "Core context saved as zero on riscv64");
   end Save_Core_Context;

end Arch.Context;
