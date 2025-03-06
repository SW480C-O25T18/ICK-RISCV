with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context; use Arch.Context;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Test.Stubs; use Test.Stubs;
package body CSR_Extension_Tests is

   procedure Test_MISA_Value (T : in out Test_Case'Class) is
   begin
      Check_True(MISA_Value /= 0, "Cached MISA_Value must be nonzero");
   end Test_MISA_Value;

   procedure Test_FP_Extension_Bits (T : in out Test_Case'Class) is
   begin
      if (MISA_Value and F_Extension_Bit) /= 0 then
         Check_True(Has_Extension(F_Extension_Bit), "F extension should be detected");
      else
         Check_True(not Has_Extension(F_Extension_Bit), "F extension should not be detected");
      end if;
      
      if (MISA_Value and D_Extension_Bit) /= 0 then
         Check_True(Has_Extension(D_Extension_Bit), "D extension should be detected");
      else
         Check_True(not Has_Extension(D_Extension_Bit), "D extension should not be detected");
      end if;
   end Test_FP_Extension_Bits;

   procedure Register_Tests (T : in out CSR_Extension_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_MISA_Value'Access, "Test_MISA_Value");
      Register_Routine(T, Test_FP_Extension_Bits'Access, "Test_FP_Extension_Bits");
   end Register_Tests;

   overriding function Name (T : CSR_Extension_Test) return Message_String is
   begin
      return "CSR_Extension_Tests";
   end Name;

end CSR_Extension_Tests;
