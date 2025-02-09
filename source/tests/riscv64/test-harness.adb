with AUnit.Run;
with Test_Suite;
with Ada.Text_IO;

procedure Test_Harness is
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Ada.Text_IO.Put_Line ("Running RISC-V Context Switch Tests...");
   AUnit.Run.Run (Test_Suite.Suite, Reporter);
end Test_Harness;
