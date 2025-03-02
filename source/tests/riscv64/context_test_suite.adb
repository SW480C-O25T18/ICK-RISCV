with AUnit.Test_Suites;
with GP_Context_Tests;
with CSR_Extension_Tests;
with FP_Context_Tests;
with Core_Context_Tests;
with Success_Fork_Result_Tests;
package body Context_Test_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : AUnit.Test_Suites.Access_Test_Suite := AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test(AUnit.Test_Suites.Access_Test_Suite(GP_Context_Tests.Test_Case'Access));
      Result.Add_Test(AUnit.Test_Suites.Access_Test_Suite(CSR_Extension_Tests.Test_Case'Access));
      Result.Add_Test(AUnit.Test_Suites.Access_Test_Suite(FP_Context_Tests.Test_Case'Access));
      Result.Add_Test(AUnit.Test_Suites.Access_Test_Suite(Core_Context_Tests.Test_Case'Access));
      Result.Add_Test(AUnit.Test_Suites.Access_Test_Suite(Success_Fork_Result_Tests.Test_Case'Access));
      return Result;
   end Suite;

end Context_Test_Suite;
