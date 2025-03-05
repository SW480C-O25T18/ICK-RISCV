with AUnit.Reporter.Text;
with AUnit.Run;
with Arch_RV64_Test_Suite;
with Ada.Text_IO;
with Test.Stubs; use Test.Stubs;

procedure Test_Harness is
   -- Instantiate the test runner for the RISC-V context switch test suite.
   procedure Run is new AUnit.Run.Test_Runner(Arch_RV64_Test_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   -- Initialize the test stubs so that Core_Locals and other hardware-dependent behaviors are simulated.
   Initialize_Core_Locals;

   Ada.Text_IO.Put_Line("Running RISC-V Context Switch Tests...");
   Run(Reporter);
end Test_Harness;
