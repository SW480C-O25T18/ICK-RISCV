-- Composition package:
with AUnit; use AUnit;
with AUnit.Test_Suites; use AUnit.Test_Suites;

package Arch_RV64_Test_Suite is
   function Suite return Test_Suites.Access_Test_Suite;
end Arch_RV64_Test_Suite;