with AUnit.Reporter.Text;
with AUnit.Run;
with Arch_RV64_Test_Suite;
with Ada.Text_IO;

procedure Test_Harness is
   procedure Run is new AUnit.Run.Test_Runner (Arch_RV64_Test_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Ada.Text_IO.Put_Line ("Running RISC-V Context Switch Tests...");
   Run (Reporter);
end Test_Harness;