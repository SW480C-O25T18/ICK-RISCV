with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package FP_Context_Tests is
   type FP_Context_Test is new Test_Cases.Test_Case with null record;
   Test_Case : aliased FP_Context_Test := new FP_Context_Test'(Name => "FP_Context_Tests");
   procedure Register_Tests (T : in out FP_Context_Test);
   function Name (T : FP_Context_Test) return Message_String;
end FP_Context_Tests;
