--  lib-runtime.ads: Functions needed by the compiler.
--  Copyright (C) 2023 streaksu
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

with System;
with Interfaces.C; use Interfaces.C;

--  This are glue functions generated by the compiler that we must fill.
--  Most of them are for error-reporting, and the names are preset.

package Lib.Runtime with SPARK_Mode => Off is
   --  Called for runtime checks.
   procedure Last_Chance_Handler (File : System.Address; Line : Integer)
      with Export, Convention => C, Obsolescent,
           External_Name => "__gnat_last_chance_handler";
   ----------------------------------------------------------------------------
   --  These functions are called for memory moves and copying primitives.
   function MemCmp (S1, S2 : System.Address; Size : size_t) return int
      with Export, Convention => C, External_Name => "memcmp", Obsolescent;
   function MemCpy
      (Desto, Source : System.Address;
       Size          : size_t) return System.Address
      with Export, Convention => C, External_Name => "memcpy", Obsolescent;
   function MemMove
      (Desto, Source : System.Address;
       Size          : size_t) return System.Address
      with Export, Convention => C, External_Name => "memmove", Obsolescent;
   function MemSet
      (Desto : System.Address;
       Value : Integer;
       Size  : size_t) return System.Address
      with Export, Convention => C, External_Name => "memset", Obsolescent;
end Lib.Runtime;
