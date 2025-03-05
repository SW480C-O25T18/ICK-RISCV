with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Success_Fork_Result_Tests is
   type Success_Fork_Result_Test is new Test_Cases.Test_Case with null record;
   Test_Case : aliased Success_Fork_Result_Test :=
      new Success_Fork_Result_Test'(Name => "Success_Fork_Result_Tests");
   overriding procedure Register_Tests (T : in out Success_Fork_Result_Test);
   overriding function Name (T : Success_Fork_Result_Test) return Message_String;
end Success_Fork_Result_Tests;
