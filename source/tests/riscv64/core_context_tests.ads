with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Core_Context_Tests is
   type Core_Context_Test is new Test_Cases.Test_Case with null record;
   overriding function Name (T : Core_Context_Test) return Test_String;
   procedure Register_Tests (T : in out Core_Context_Test);
   Test_Case : constant access Core_Context_Test := new Core_Context_Test'(Name => "Core_Context_Tests");
end Core_Context_Tests;
