with AUnit.Test_Cases;

package Test_Context is
   type Context_Test_Case is new AUnit.Test_Cases.Test_Case with null record;

   procedure Register_Tests (T : in out Context_Test_Case);
end Test_Context;
