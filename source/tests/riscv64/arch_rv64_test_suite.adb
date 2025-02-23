--  Import tests and suites to run
with RV64_Test_Suite;
with AUnit.Tests;
package body Arch_RV64_Test_Suite is
   use Test_Suites;

   --  Here we dynamically allocate the suite using the New_Suite function
   --  We use the 'Suite' functions provided in This_Suite and That_Suite
   --  We also use Ada 2005 distinguished receiver notation to call Add_Test

   function Suite return Access_Test_Suite is
      Result : Access_Test_Suite := AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (RV64_Test_Suite.Suite);
      return Result;
   end Suite;
end Arch_RV64_Test_Suite;