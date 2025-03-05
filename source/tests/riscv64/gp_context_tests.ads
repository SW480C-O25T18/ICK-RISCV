with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package GP_Context_Tests is
   type GP_Context_Test is new Test_Cases.Test_Case with null record;
   Test_Case : aliased GP_Context_Test :=
     new GP_Context_Test'(Name => "GP_Context_Tests");
   overriding procedure Register_Tests (T : in out GP_Context_Test);
   overriding function Name (T : GP_Context_Test) return Message_String;
end GP_Context_Tests;
