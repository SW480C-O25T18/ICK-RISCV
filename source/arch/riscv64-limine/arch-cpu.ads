--  arch-cpu.ads: CPU management routines.
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

with Interfaces; use Interfaces;
with Userland.Process;
with Scheduler;
with Arch.Limine;

package Arch.CPU is
   --  Core-local data, that each core holds an own version of.
   type Core_Local;
   type Core_Local_Acc is access all Core_Local;
   type Core_Local is record
      --  Do not move the following members used in assembly code.
      Self            : Core_Local_Acc; --  Here for performance reasons.
      Kernel_Stack    : Unsigned_64;
      User_Stack      : Unsigned_64;
      --  End of members not to move.
      Number          : Positive;       --  Core number, 1 based.
      Hart_ID         : Unsigned_64;    --  LAPIC ID of the core.
      Current_Thread  : Scheduler.TID;
      Current_Process : Userland.Process.PID;
   end record;
   for Core_Local use record
      Self         at 0 range   0 ..  63;
      Kernel_Stack at 0 range  64 .. 127;
      User_Stack   at 0 range 128 .. 191;
   end record;

   --  Core locals and the number of cores, used as an index for the former.
   type Core_Local_Arr is array (Positive range <>) of aliased Core_Local;
   type Core_Local_Arr_Acc is access Core_Local_Arr;
   Core_Count  : Positive;
   Core_Locals : Core_Local_Arr_Acc;

   --  Init the cores and BSP.
   procedure Init_Cores;

private

   procedure Core_Bootstrap (Info : access Limine.RISCV64_SMP_CPU_Info)
      with Convention => C, Export;

   procedure Init_Common (Core_Number : Positive; Hart_ID : Unsigned_64);
end Arch.CPU;