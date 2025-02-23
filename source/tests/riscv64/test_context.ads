with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package Test_Context is

   overriding procedure Register_Tests (T: in out Test_Context);
   overriding function Name (T: Test_Context) return Message_String;

   -- Test Routines:
   procedure Test_Init_GP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Load_GP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Save_Core_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Success_Fork_Result (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Init_FP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Save_FP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Load_FP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Destroy_FP_Context (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Get_Hart_ID (T : in out Test_Cases.Test_Case'Class);
   procedure Test_Has_Extension (T : in out Test_Cases.Test_Case'Class);

end Test_Context;