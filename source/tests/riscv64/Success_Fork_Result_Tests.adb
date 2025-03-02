with AUnit.Framework;
with Arch.Context; use Arch.Context;
with Arch.Interrupts; use Arch.Interrupts;
with Interfaces; use Interfaces;
with Memory.Physical;
with System;

procedure Success_Fork_Result_Tests is
   package Test is new AUnit.Framework.Test_Case("Success_Fork_Result_Tests");

   -- Test_Success_Fork verifies that Success_Fork_Result properly sets A0 to 0
   -- and advances SEPC by 4 bytes.
   procedure Test_Success_Fork is
      Ctx         : GP_Context;
      Dummy_Stack : System.Address := Memory.Physical.Alloc(4096);
      -- Provide a nonzero dummy start address.
      Dummy_Start : constant System.Address := System.Address'Value(16#30000#);
      Old_Internal, New_Internal : GP_Context_Type;
   begin
      -- Initialize the GP context.
      Init_GP_Context(Ctx, Dummy_Stack, Dummy_Start);
      Old_Internal := To_GP_Context_Type(Ctx);
      Test.Check_True(Old_Internal.SEPC /= 0, "Precondition: Old SEPC must be nonzero");
      
      -- Perform the fork result adjustment.
      Success_Fork_Result(Ctx);
      
      New_Internal := To_GP_Context_Type(Ctx);
      Test.Check_Equal(0, New_Internal.A0, "Forked process should return 0 in A0");
      Test.Check_Equal(Old_Internal.SEPC + 4, New_Internal.SEPC, "SEPC should be advanced by 4 bytes after fork");
   end Test_Success_Fork;

begin
   Test.Register(Test_Success_Fork'Access);
   Test.Run;
end Success_Fork_Result_Tests;
