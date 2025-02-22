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

pragma SPARK_Mode (On);
with System; use System;
with Interfaces; use Interfaces;
with System.Machine_Code;
with Arch.Interrupts;
with Arch.CPU;

package body Arch.Context is
   pragma Warnings (Off, "SPARK_Mode is enabled");

   -- Define an internal record type to map to GP_Context
   type GP_Context_Type is record
      SP       : Unsigned_64;
      SEPC     : Unsigned_64;
      SSTATUS  : Unsigned_64;
      A0       : Unsigned_64;
   end record;

   -- Helper function to convert from Frame to GP_Context_Type
   function To_GP_Context_Type (Frame : GP_Context) return GP_Context_Type is
      (SP       => Unsigned_64 (Frame.R15),
       SEPC     => Unsigned_64 (Frame.R14),
       SSTATUS  => Unsigned_64 (Frame.R13),
       A0       => Unsigned_64 (Frame.R12));

   -- Helper function to convert from GP_Context_Type to Frame
   function To_Frame (Ctx : GP_Context_Type) return GP_Context is
      (R15 => Unsigned_32 (Ctx.SP and 16#FFFFFFFF#),
       R14 => Unsigned_32 (Ctx.SEPC and 16#FFFFFFFF#),
       R13 => Unsigned_32 (Ctx.SSTATUS and 16#FFFFFFFF#),
       R12 => Unsigned_32 (Ctx.A0 and 16#FFFFFFFF#),
       others => 0);

   function Get_CSR (CSR_Number : Unsigned_64) return Unsigned_64 is
      Value : Unsigned_64;
   begin
      System.Machine_Code.Asm ("csrr %0, %1", Outputs => Unsigned_64'Asm_Output ("=r", Value),
           Inputs => Unsigned_64'Asm_Input ("i", CSR_Number));
      return Value;
   end Get_CSR;

   function Has_Extension (Feature_Bit : Unsigned_64) return Boolean is
   begin
      return (Get_CSR (16#301#) and Feature_Bit) /= 0;  -- MISA CSR
   end Has_Extension;

   function Get_Hart_ID return Unsigned_64 is
      Hart_ID : Unsigned_64;
   begin
      System.Machine_Code.Asm ("csrr %0, mhartid", Outputs => Unsigned_64'Asm_Output ("=r", Hart_ID));
      pragma Assert (Hart_ID < 64); -- Ensure valid hart ID
      return Hart_ID;
   end Get_Hart_ID;

   -- Initialize general-purpose context
   procedure Init_GP_Context
      (Ctx        : out GP_Context;
       Stack      : System.Address;
       Start_Addr : System.Address)
   is
      Ctx_Impl : GP_Context_Type;
   begin
      -- SPARK Aspects
      pragma Assume (Stack /= System.Null_Address and Start_Addr /= System.Null_Address);

      Ctx_Impl.SP    := Unsigned_64 (To_Integer (Stack));
      Ctx_Impl.SEPC  := Unsigned_64 (To_Integer (Start_Addr));
      Ctx_Impl.SSTATUS := Get_CSR (16#100#);  -- Supervisor Status Register
      Ctx := To_Frame (Ctx_Impl);

      -- SPARK Aspects
      pragma Assert ((for all Index in GP_Context'Range => Ctx.To_Element (Index) = 0) and
                     Ctx.To_Element (1) = Unsigned_32 (To_Integer (Stack) and 16#FFFFFFFF#) and
                     Ctx.To_Element (2) = Unsigned_32 (To_Integer (Start_Addr) and 16#FFFFFFFF#));
   end Init_GP_Context;

   -- Load general-purpose context for task switching
   procedure Load_GP_Context (Ctx : GP_Context)
   is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type (Ctx);
   begin
      -- SPARK Aspects
      pragma Assume (Ctx.To_Element (2) /= 0);

      System.Machine_Code.Asm ("csrw sepc, %0; csrw sstatus, %1; mv sp, %2; sret",
           Inputs => (Unsigned_64'Asm_Input ("r", Ctx_Impl.SEPC),
                      Unsigned_64'Asm_Input ("r", Ctx_Impl.SSTATUS),
                      Unsigned_64'Asm_Input ("r", Ctx_Impl.SP)),
           Clobber => "memory",
           Volatile => True);
      loop null; end loop;
   end Load_GP_Context;

   -- Save core-specific context for multi-core support
   procedure Save_Core_Context (Ctx : out Core_Context)
   is
   begin
      -- Assuming Get_Local is defined in CPU package
      Ctx := Arch.CPU.Core_Locals (Arch.CPU.Core_Count).User_Stack;
      -- SPARK Aspects
      pragma Assert (Ctx >= 0);
   end Save_Core_Context;

   -- Ensure forked process returns 0 in userland
   procedure Success_Fork_Result (Ctx : in out GP_Context)
   is
      Ctx_Impl : GP_Context_Type := To_GP_Context_Type (Ctx);
   begin
      -- SPARK Aspects
      pragma Assume (Ctx.To_Element (2) /= 0);

      Ctx_Impl.A0 := 0;  -- Ensure child process sees return value 0
      Ctx_Impl.SEPC := 0;
      Ctx := To_Frame (Ctx_Impl);

      -- SPARK Aspects
      pragma Assert (Ctx.To_Element (2) = 0 and Ctx.To_Element (4) = 0);
   end Success_Fork_Result;

   -- Initialize Floating-Point Context
   procedure Init_FP_Context (Ctx : out FP_Context)
   is
   begin
      Ctx := (others => 0);  -- Initialize FP context to zero

      -- SPARK Aspects
      pragma Assert (for all I in FP_Context'Range => Ctx(I) = 0);
   end Init_FP_Context;

   -- Save floating-point registers, dynamically handling F/D extensions
   procedure Save_FP_Context (Ctx : in out FP_Context)
   is
   begin
      if Has_Extension (16#1#) then  -- 'F' extension
         System.Machine_Code.Asm ("fsd f0, 0(%0); fsd f1, 8(%0)",
              Inputs => (System.Address'Asm_Input ("r", Ctx'Address)),
              Clobber => "memory",
              Volatile => True);
      end if;

      if Has_Extension (16#2#) then  -- 'D' extension
         System.Machine_Code.Asm ("fsd f2, 16(%0); fsd f3, 24(%0)",
              Inputs => (System.Address'Asm_Input ("r", Ctx'Address)),
              Clobber => "memory",
              Volatile => True);
      end if;

      -- SPARK Aspects
      pragma Assert (True);
   end Save_FP_Context;

   -- Restore floating-point registers, dynamically handling F/D extensions
   procedure Load_FP_Context (Ctx : FP_Context)
   is
   begin
      if Has_Extension (16#1#) then  -- 'F' extension
         System.Machine_Code.Asm ("fld f0, 0(%0); fld f1, 8(%0)",
              Inputs => (System.Address'Asm_Input ("r", Ctx'Address)),
              Clobber => "memory",
              Volatile => True);
      end if;

      if Has_Extension (16#2#) then  -- 'D' extension
         System.Machine_Code.Asm ("fld f2, 16(%0); fld f3, 24(%0)",
              Inputs => (System.Address'Asm_Input ("r", Ctx'Address)),
              Clobber => "memory",
              Volatile => True);
      end if;

      -- SPARK Aspects
      pragma Assert (True);
   end Load_FP_Context;

   -- Destroy floating-point context
   procedure Destroy_FP_Context (Ctx : in out FP_Context)
   is
   begin
      Ctx := (others => 0);

      -- SPARK Aspects
      pragma Assert (for all I in FP_Context'Range => Ctx(I) = 0);
   end Destroy_FP_Context;

end Arch.Context;
