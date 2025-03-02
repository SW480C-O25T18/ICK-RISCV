with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Success_Fork_Result_Tests is
   type Success_Fork_Test is new Test_Cases.Test_Case with null record;
   procedure Register_Tests (T : in out Success_Fork_Test);
   function Name (T : Success_Fork_Test) return Message_String;
end Success_Fork_Result_Tests;
