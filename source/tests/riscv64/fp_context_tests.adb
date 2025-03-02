with AUnit.Test_Cases;
with Arch.Context; use Arch.Context;
with Interfaces; use Interfaces;

procedure FP_Context_Tests is

   package Test is new AUnit.Test_Cases.Test_Case("FP_Context_Tests");

   -- Dummy FP context (assumed to be an array of Unsigned_8)
   Dummy_FP_Context : FP_Context;

   -------------------------------------------------------------------
   -- Test FP context initialization zeroes all elements.
   -------------------------------------------------------------------
   procedure Test_Init_FP_Context is
      I : Integer;
   begin
      Init_FP_Context(Dummy_FP_Context);
      for I in FP_Context'Range loop
         Test.Check_Equal(0, Dummy_FP_Context(I),
            "FP context element " & I'Image & " should be zero after initialization");
      end loop;
   end Test_Init_FP_Context;

   -------------------------------------------------------------------
   -- Test FP context destruction zeroes all elements.
   -------------------------------------------------------------------
   procedure Test_Destroy_FP_Context is
      I : Integer;
   begin
      Init_FP_Context(Dummy_FP_Context);
      Destroy_FP_Context(Dummy_FP_Context);
      for I in FP_Context'Range loop
         Test.Check_Equal(0, Dummy_FP_Context(I),
            "FP context element " & I'Image & " should be zero after destruction");
      end loop;
   end Test_Destroy_FP_Context;

   -------------------------------------------------------------------
   -- Test FP dispatch routines are set.
   -------------------------------------------------------------------
   procedure Test_FP_Dispatch is
   begin
      Setup_FP_Routines;
      Test.Check_True(FP_Save_Routine /= null, "FP_Save_Routine must not be null");
      Test.Check_True(FP_Load_Routine /= null, "FP_Load_Routine must not be null");
   end Test_FP_Dispatch;

begin
   Test.Register(Test_Init_FP_Context'Access);
   Test.Register(Test_Destroy_FP_Context'Access);
   Test.Register(Test_FP_Dispatch'Access);
   Test.Run;
end FP_Context_Tests;
