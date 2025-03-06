with Interfaces;
with System;
with System.Storage_Elements; use System.Storage_Elements;

package body Stubs is

   procedure Initialize_Core_Locals is
   begin
      for I in Core_Locals'Range loop
         declare
            -- Convert the integer expression to type Integer_Address.
            A : Integer_Address := Integer_Address(16#1000# + I * 16#100#);
         begin
            Core_Locals(I).User_Stack := To_Address(A);
         end;
         -- Explicitly convert to Unsigned_64.
         Core_Locals(I).Hart_ID := Unsigned_64(I - 1);
         Core_Locals(I).Number  := I;
      end loop;
   end Initialize_Core_Locals;

   function Has_Extension(Bit : Unsigned_64) return Boolean is
   begin
      -- Convert numeric literals to Unsigned_64 to match the type of Bit.
      if Bit = Unsigned_64(16#20#) or Bit = Unsigned_64(16#40#) then
         return True;
      else
         return False;
      end if;
   end Has_Extension;
end Stubs;
