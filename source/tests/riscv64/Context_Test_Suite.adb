with AUnit.Test_Suites;
with CSR_Extension_Tests;
with Core_Context_Tests;
with FP_Context_Tests;
with GP_Context_Tests;

package body Context_Test_Suite is
   use AUnit.Test_Suites;

   Result : aliased Test_Suite;

   function Suite return Access_Test_Suite is
   begin
      Add_Test (Result'Access, CSR_Extension_Tests.Test_Case'Access);
      Add_Test (Result'Access, Core_Context_Tests.Test_Case'Access);
      Add_Test (Result'Access, FP_Context_Tests.Test_Case'Access);
      Add_Test (Result'Access, GP_Context_Tests.Test_Case'Access);
      Add_Test (Result'Access, Success_Fork_Result_Tests.Test_Case'Access);
      return Result'Access;
   end Suite;
end Context_Test_Suite;