with Interfaces;
with System;
package Stubs is
   type Core_Context_Record is record
      User_Stack : System.Address;
      Hart_ID    : Interfaces.Unsigned_64;
      Number     : Positive;
   end record;

   Core_Count : constant Positive := 4;
   -- Simulated per-core local storage.
   Core_Locals : array (Positive range 1 .. Core_Count) of Core_Context_Record;

   -- For testing, initialize Core_Locals with dummy values.
   procedure Initialize_Core_Locals;

   -- Stub for FP extension detection.
   function Has_Extension(Bit : Interfaces.Unsigned_64) return Boolean;
end Test.Stubs;
