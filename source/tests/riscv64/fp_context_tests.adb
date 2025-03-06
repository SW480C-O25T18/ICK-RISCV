with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context; use Arch.Context;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Interfaces; use Interfaces;

package body FP_Context_Tests is

   Dummy_FP_Context : FP_Context;

   procedure Test_Init_FP_Context (T : in out Test_Case'Class) is
      I : Integer;
   begin
      Init_FP_Context(Dummy_FP_Context);
      for I in FP_Context'Range loop
         Check_Equal(0, Dummy_FP_Context(I),
            "FP context element " & I'Image & " should be zero after initialization");
      end loop;
   end Test_Init_FP_Context;

   procedure Test_Destroy_FP_Context (T : in out Test_Case'Class) is
      I : Integer;
   begin
      Init_FP_Context(Dummy_FP_Context);
      Destroy_FP_Context(Dummy_FP_Context);
      for I in FP_Context'Range loop
         Check_Equal(0, Dummy_FP_Context(I),
            "FP context element " & I'Image & " should be zero after destruction");
      end loop;
   end Test_Destroy_FP_Context;

   procedure Test_FP_Dispatch (T : in out Test_Case'Class) is
   begin
      Setup_FP_Routines;
      Check_True(FP_Save_Routine /= null, "FP_Save_Routine must not be null");
      Check_True(FP_Load_Routine /= null, "FP_Load_Routine must not be null");
   end Test_FP_Dispatch;

   procedure Register_Tests (T : in out FP_Context_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_Init_FP_Context'Access, "Test_Init_FP_Context");
      Register_Routine(T, Test_Destroy_FP_Context'Access, "Test_Destroy_FP_Context");
      Register_Routine(T, Test_FP_Dispatch'Access, "Test_FP_Dispatch");
   end Register_Tests;

   overriding function Name (T : FP_Context_Test) return Message_String is
   begin
      return "FP_Context_Tests";
   end Name;

end FP_Context_Tests;
