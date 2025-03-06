with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package FP_Context_Tests is
   type FP_Context_Test is new Test_Cases.Test_Case with null record;
   overriding function Name (T : FP_Context_Test) return Test_String;
   procedure Register_Tests (T : in out FP_Context_Test);
   Test_Case : constant access FP_Context_Test := new FP_Context_Test'(Name => "FP_Context_Tests");
end FP_Context_Tests;
