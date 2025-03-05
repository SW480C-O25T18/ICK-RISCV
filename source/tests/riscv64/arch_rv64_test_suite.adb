with AUnit.Test_Suites;
with Context_Test_Suite;
package body Arch_RV64_Test_Suite is
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      return Context_Test_Suite.Suite;
   end Suite;
end Arch_RV64_Test_Suite;
