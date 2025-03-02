with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package CSR_Extension_Tests is
   type CSR_Extension_Test is new Test_Cases.Test_Case with null record;
   Test_Case : aliased CSR_Extension_Test := new CSR_Extension_Test'(Name => "CSR_Extension_Tests");
   overriding procedure Register_Tests (T : in out CSR_Extension_Test);
   overriding function Name (T : CSR_Extension_Test) return Message_String;
end CSR_Extension_Tests;
