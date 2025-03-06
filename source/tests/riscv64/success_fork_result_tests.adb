with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context; use Arch.Context;
with Memory.Physical;
with System;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package body Success_Fork_Result_Tests is

   procedure Test_Success_Fork_Result (T : in out Test_Case'Class) is
      Ctx         : Arch.Context.GP_Context;
      Stack       : System.Address := Memory.Physical.Alloc(4096);
      Dummy_Start : constant System.Address := System.Address'Value(16#6000#);
      Internal    : Arch.Context.GP_Context_Type;
      Old_SEPC    : Unsigned_64;
   begin
      Arch.Context.Init_GP_Context(Ctx, Stack, Dummy_Start);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Old_SEPC := Internal.SEPC;
      Arch.Context.Success_Fork_Result(Ctx);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Check_Equal(0, Internal.A0, "A0 should be set to 0 by Success_Fork_Result");
      Check_True(Internal.SEPC > Old_SEPC, "SEPC should advance after Success_Fork_Result");
   end Test_Success_Fork_Result;

   overriding procedure Register_Tests (T : in out Success_Fork_Result_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_Success_Fork_Result'Access, "Test_Success_Fork_Result");
   end Register_Tests;

   overriding function Name (T : Success_Fork_Result_Test) return Test_String is
   begin
      return "Success_Fork_Result_Tests";
   end Name;

end Success_Fork_Result_Tests;
