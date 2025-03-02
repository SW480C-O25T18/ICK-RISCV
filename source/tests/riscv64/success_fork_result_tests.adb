with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context; use Arch.Context;
with Arch.Interrupts; use Arch.Interrupts;
with Interfaces; use Interfaces;
with Memory.Physical;
with System;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package body Success_Fork_Result_Tests is

   procedure Test_Success_Fork (T : in out Test_Case'Class) is
      Ctx         : GP_Context;
      Dummy_Stack : System.Address := Memory.Physical.Alloc(4096);
      Dummy_Start : constant System.Address := System.Address'Value(16#30000#);
      Old_Internal, New_Internal : GP_Context_Type;
   begin
      Init_GP_Context(Ctx, Dummy_Stack, Dummy_Start);
      Old_Internal := To_GP_Context_Type(Ctx);
      Check_True(Old_Internal.SEPC /= 0, "Precondition: Old SEPC must be nonzero");
      
      Success_Fork_Result(Ctx);
      
      New_Internal := To_GP_Context_Type(Ctx);
      Check_Equal(0, New_Internal.A0, "Forked process should return 0 in A0");
      Check_Equal(Old_Internal.SEPC + 4, New_Internal.SEPC,
                    "SEPC should be advanced by 4 bytes after fork");
   end Test_Success_Fork;

   procedure Register_Tests (T : in out Success_Fork_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_Success_Fork'Access, "Test_Success_Fork");
   end Register_Tests;

   function Name (T : Success_Fork_Test) return Message_String is
   begin
      return "Success_Fork_Result_Tests";
   end Name;

end Success_Fork_Result_Tests;
