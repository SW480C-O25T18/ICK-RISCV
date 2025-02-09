--  arch-context.ads: Architecture-specific context switching.
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

--  arch-context.adb: Architecture-specific context switching for RISC-V 64-bit
--  SPDX-License-Identifier: GPL-3.0-or-later

with System; with Arch.CPU;
pragma SPARK_Mode (On);

package body Arch.Context is

   -- Get hart ID for multi-core support (Single-Core returns 0)
   function Get_Hart_ID return Unsigned_64
   with
      Global => null,
      Post   => Get_Hart_ID < 64  -- Ensures valid hart ID
   is
      HartID : Unsigned_64;
   begin
      -- Read the hart ID from the mhartid CSR
      Asm ("csrr %0, mhartid", Outputs => Unsigned_64'Asm_Output ("=r", HartID));
      return HartID;
   end Get_Hart_ID;


   -- Check if the CPU supports a given extension in `misa`
   function Has_Extension (Feature_Bit : Unsigned_64) return Boolean
   with
      Global => null,
      Post   => Has_Extension'Result = ((Get_CSR (16#F11#) and Feature_Bit) /= 0)
   is
   begin
      return (Get_CSR (16#F11#) and Feature_Bit) /= 0;
   end Has_Extension;

   -- Get the number of FP registers based on MISA
   function Get_Num_FP_Registers return Natural
   with
      Global => null,
      Post   => Get_Num_FP_Registers in 0 .. 32
   is
      MISA_Value : Unsigned_64 := Get_CSR (16#F11#);
   begin
      if (MISA_Value and 16#20#) /= 0 then  -- Check 'D' bit for double-precision
         return 32;
      elsif (MISA_Value and 16#10#) /= 0 then  -- Check 'F' bit for single-precision
         return 16;
      else
         return 0;
      end if;
   end Get_Num_FP_Registers;

   -- Initialize General-Purpose Context
   procedure Init_GP_Context
      (Ctx        : out GP_Context;
      Stack      : System.Address;
      Start_Addr : System.Address)
   with
      Pre  => Stack /= System.Null_Address and Start_Addr /= System.Null_Address,
      Post => Ctx.SEPC = Unsigned_64 (To_Integer (Start_Addr)) and
            Ctx.SP = Unsigned_64 (To_Integer (Stack))
   is
      SSTATUS_Value : Unsigned_64;
      Hart          : Unsigned_64 := Get_Hart_ID;  -- Get core ID
   begin
      -- Read current SSTATUS and configure correctly
      Asm ("csrr %0, sstatus", Outputs => Unsigned_64'Asm_Output ("=r", SSTATUS_Value));
      SSTATUS_Value := SSTATUS_Value or 16#00040020#;

      -- Assertions to ensure SSTATUS_Value is correctly set
      pragma Assert ((SSTATUS_Value and 16#00040020#) /= 0, "SSTATUS_Value not correctly set");

      -- Assign core-specific context
      Per_Core_Context (Hart) := (
         SEPC    => Unsigned_64 (To_Integer (Start_Addr)),
         SSTATUS => SSTATUS_Value,
         SP      => Unsigned_64 (To_Integer (Stack)),
         others  => 0
      );

      -- Assertions to ensure the context is correctly assigned
      pragma Assert (Per_Core_Context (Hart).SEPC = Unsigned_64 (To_Integer (Start_Addr)), "SEPC not correctly assigned");
      pragma Assert (Per_Core_Context (Hart).SP = Unsigned_64 (To_Integer (Stack)), "SP not correctly assigned");
      pragma Assert (Per_Core_Context (Hart).SSTATUS = SSTATUS_Value, "SSTATUS not correctly assigned");

      -- Return reference to correct per-core context
      Ctx := Per_Core_Context (Hart);

      -- Assertions to ensure the output context is correctly set
      pragma Assert (Ctx.SEPC = Unsigned_64 (To_Integer (Start_Addr)), "Output SEPC not correctly set");
      pragma Assert (Ctx.SP = Unsigned_64 (To_Integer (Stack)), "Output SP not correctly set");
      pragma Assert (Ctx.SSTATUS = SSTATUS_Value, "Output SSTATUS not correctly set");

      -- Inline assembly to load the general-purpose context and return from the trap
      Asm (
         "ld ra, 0(%0)"   & LF & HT &
         "ld sp, 8(%0)"   & LF & HT &
         "ld gp, 16(%0)"  & LF & HT &
         "csrw sepc, %1"  & LF & HT &
         "csrw sstatus, %2" & LF & HT &
         "sret",
         Inputs   => (System.Address'Asm_Input ("r", Ctx'Address),
                     Register'Asm_Input ("r", Ctx.SEPC),
                     Register'Asm_Input ("r", Ctx.SSTATUS)),
         Clobber  => "memory",
         Volatile => True
      );
   end Init_GP_Context;


   -- Load General-Purpose Context (Supports Multi-Core)
   procedure Load_GP_Context (Ctx : GP_Context) is
   begin
      pragma Assert (Ctx.SEPC /= 0, "Load_GP_Context: SEPC must not be zero!");
      pragma Assert (Ctx.SP /= 0, "Load_GP_Context: Stack Pointer must not be zero!");

      -- Load context and return to user space
      Asm (
         "ld ra, 0(%0)"   & LF & HT &
         "ld sp, 8(%0)"   & LF & HT &
         "ld gp, 16(%0)"  & LF & HT &
         "ld tp, 24(%0)"  & LF & HT &
         "ld t0, 32(%0)"  & LF & HT &
         "ld t1, 40(%0)"  & LF & HT &
         "ld t2, 48(%0)"  & LF & HT &
         "ld s0, 56(%0)"  & LF & HT &
         "ld s1, 64(%0)"  & LF & HT &
         "ld a0, 72(%0)"  & LF & HT &
         "ld a1, 80(%0)"  & LF & HT &
         "ld a2, 88(%0)"  & LF & HT &
         "ld a3, 96(%0)"  & LF & HT &
         "ld a4, 104(%0)" & LF & HT &
         "ld a5, 112(%0)" & LF & HT &
         "ld a6, 120(%0)" & LF & HT &
         "ld a7, 128(%0)" & LF & HT &
         "ld s2, 136(%0)" & LF & HT &
         "ld s3, 144(%0)" & LF & HT &
         "ld s4, 152(%0)" & LF & HT &
         "ld s5, 160(%0)" & LF & HT &
         "ld s6, 168(%0)" & LF & HT &
         "ld s7, 176(%0)" & LF & HT &
         "ld s8, 184(%0)" & LF & HT &
         "ld s9, 192(%0)" & LF & HT &
         "ld s10, 200(%0)"& LF & HT &
         "ld s11, 208(%0)"& LF & HT &
         "ld t3, 216(%0)" & LF & HT &
         "ld t4, 224(%0)" & LF & HT &
         "ld t5, 232(%0)" & LF & HT &
         "ld t6, 240(%0)" & LF & HT &
         "ld sepc, 248(%0)" & LF & HT &
         "ld sstatus, 256(%0)" & LF & HT &
         "sret",
         Inputs   => (System.Address'Asm_Input ("r", Ctx'Address),
                      Unsigned_64'Asm_Input ("r", Ctx.SEPC),
                      Unsigned_64'Asm_Input ("r", Ctx.SSTATUS)),
         Clobber  => "memory",
         Volatile => True
      );

      -- Infinite loop for debugging if we accidentally return here
      loop null; end loop;
   end Load_GP_Context;

   -- Save Core Context (Multi-Core Safe)
   procedure Save_Core_Context (Ctx : out Core_Context)
   with
      Post => Ctx >= 0
   is
   begin
      Ctx := Arch.CPU.Get_Local.User_Stack;
   end Save_Core_Context;

   -- Indicate Successful Fork
   procedure Success_Fork_Result (Ctx : in out GP_Context)
   with
      Pre  => Ctx.SEPC /= 0,  -- Ensure valid program counter
      Post => Ctx.SEPC = 0 and Ctx.A0 = 0  -- Ensure child process returns 0
   is
   begin
      -- Set child process return value (RV ABI: A0 register)
      Ctx.A0 := 0;  

      -- Clear SEPC for child execution start
      Ctx.SEPC := 0;
   end Success_Fork_Result;


   -- Initialize Floating-Point Context
   procedure Init_FP_Context (Ctx : out FP_Context)
   with
      Pre  => True,
      Post => True
   is
      Num_FP_Regs : Natural := Get_Num_FP_Registers;
   begin
      if Num_FP_Regs > 0 then
      -- Initialize FP registers to 0.0
      for I in 0 .. Num_FP_Regs - 1 loop
         Ctx.FP_Regs (I) := 0.0;  -- Initialize FP register to 0.0
      end loop;
      end if;
   end Init_FP_Context;

   -- Save Floating-Point Context (Handles Multi-Core)
   procedure Save_FP_Context (Ctx : in out FP_Context)
   with
      Pre  => Ctx /= System.Null_Address,
      Post => True
   is
   begin
      if Has_Extension (16#1#) then
         Asm ("fsd f0, 0(%0)", Inputs => System.Address'Asm_Input ("r", Ctx));
      end if;
   end Save_FP_Context;

   -- Load Floating-Point Context (Handles Multi-Core)
   procedure Load_FP_Context (Ctx : FP_Context)
   with
      Pre  => Ctx /= System.Null_Address,
      Post => True
   is
   begin
      if Has_Extension (16#1#) then
         Asm ("fld f0, 0(%0)", Inputs => System.Address'Asm_Input ("r", Ctx));
      end if;
   end Load_FP_Context;

   -- Destroy Floating-Point Context
   procedure Destroy_FP_Context (Ctx : in out FP_Context)
   with
      Pre  => Ctx /= System.Null_Address,
      Post => Ctx = System.Null_Address
   is
   begin
      Ctx := System.Null_Address;
   end Destroy_FP_Context;

end Arch.Context;
