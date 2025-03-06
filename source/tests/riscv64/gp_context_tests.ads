with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package GP_Context_Tests is
   type GP_Context_Test is new Test_Cases.Test_Case with null record;
   overriding function Name (T : GP_Context_Test) return Test_String;
   procedure Register_Tests (T : in out GP_Context_Test);
   -- Changed from an aliased object to a constant access object.
   Test_Case : constant access GP_Context_Test := new GP_Context_Test'(Name => "GP_Context_Tests");
end GP_Context_Tests;
