with AUnit.Framework;
with Arch.Context; use Arch.Context;

procedure CSR_Extension_Tests is

   package Test is new AUnit.Framework.Test_Case("CSR_Extension_Tests");

   -------------------------------------------------------------------
   -- Test to verify that the cached MISA_Value is nonzero.
   -------------------------------------------------------------------
   procedure Test_MISA_Value is
   begin
      Test.Check_True(MISA_Value /= 0, "Cached MISA_Value must be nonzero");
   end Test_MISA_Value;

   -------------------------------------------------------------------
   -- Test to verify FP extension bit detection based on MISA_Value.
   -------------------------------------------------------------------
   procedure Test_FP_Extension_Bits is
   begin
      if (MISA_Value and F_Extension_Bit) /= 0 then
         Test.Check_True(Has_Extension(F_Extension_Bit),
            "F extension should be detected");
      else
         Test.Check_True(not Has_Extension(F_Extension_Bit),
            "F extension should not be detected");
      end if;
      
      if (MISA_Value and D_Extension_Bit) /= 0 then
         Test.Check_True(Has_Extension(D_Extension_Bit),
            "D extension should be detected");
      else
         Test.Check_True(not Has_Extension(D_Extension_Bit),
            "D extension should not be detected");
      end if;
   end Test_FP_Extension_Bits;

begin
   Test.Register(Test_MISA_Value'Access);
   Test.Register(Test_FP_Extension_Bits'Access);
   Test.Run;
end CSR_Extension_Tests;
