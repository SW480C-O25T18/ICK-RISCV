with Interfaces;
with System;
with System.Storage_Elements; use System.Storage_Elements;

package body Stubs is

   procedure Initialize_Core_Locals is
   begin
      for I in Core_Locals'Range loop
         declare
            A : Integer_Address := Integer_Address(16#1000# + I * 16#100#);
         begin
            Core_Locals(I).User_Stack := To_Address(A);
         end;
         Core_Locals(I).Hart_ID := Interfaces.Unsigned_64(I - 1);
         Core_Locals(I).Number  := I;
      end loop;
   end Initialize_Core_Locals;

   function Eq_U64(L, R : Interfaces.Unsigned_64) return Boolean is
   begin
      -- Compare via the 'Image attribute.
      return L'Image = R'Image;
   end Eq_U64;

   function Has_Extension(Bit : Interfaces.Unsigned_64) return Boolean is
   begin
      if Eq_U64(Bit, Interfaces.Unsigned_64(16#20#)) or else
         Eq_U64(Bit, Interfaces.Unsigned_64(16#40#))
      then
         return True;
      else
         return False;
      end if;
   end Has_Extension;
end Stubs;
