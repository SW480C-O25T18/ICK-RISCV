with Interfaces;
with System;
package body Stubs is

   procedure Initialize_Core_Locals is
   begin
      for I in Core_Locals'Range loop
         Core_Locals(I).User_Stack := System.Address'Value(16#1000# + I * 16#100#);
         Core_Locals(I).Hart_ID    := Interfaces.Unsigned_64(I - 1);
         Core_Locals(I).Number     := I;
      end loop;
   end Initialize_Core_Locals;

   function Has_Extension(Bit : Interfaces.Unsigned_64) return Boolean is
   begin
      -- For testing, assume that F (0x20) and D (0x40) extensions are supported.
      if Bit = 16#20# or Bit = 16#40# then
         return True;
      else
         return False;
      end if;
   end Has_Extension;
end Stubs;
