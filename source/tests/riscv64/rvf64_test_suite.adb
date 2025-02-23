with AUnit.Test_Suites;
with Test_Context;

package body RV64_Test_Suite is
   use AUnit.Test_Suites;

   Result : aliased Test_Suite;

   function Suite return Access_Test_Suite is
   begin
      Add_Test (Result'Access, Test_Context.Test_Case'Access);
      return Result'Access;
   end Suite;
end RV64_Test_Suite;