with AUnit.Test_Suites;
with Test_Context;

package body Test_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      TS : constant AUnit.Test_Suites.Access_Test_Suite := AUnit.Test_Suites.New_Suite;
   begin
      AUnit.Test_Suites.Add_Test (TS, new Test_Context.Context_Test_Case);
      return TS;
   end Suite;

end Test_Suite;
