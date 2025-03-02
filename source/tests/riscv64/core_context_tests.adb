with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context; use Arch.Context;
with Arch.CPU;      use Arch.CPU;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package body Core_Context_Tests is

   procedure Test_Save_Core_Context (T : in out Test_Case'Class) is
      Saved_Core   : Core_Context;
      Current_Hart : Unsigned_64;
      Core_Index   : Positive;
   begin
      Current_Hart := Get_Hart_ID;
      Core_Index   := Positive(Integer(Current_Hart) + 1);
      pragma Assert(Core_Index <= Core_Count, "Test: Core index out of bounds");
      Save_Core_Context(Saved_Core);
      Check_Equal(Core_Locals(Core_Index).User_Stack,
         Saved_Core.User_Stack,
         "Saved core context must have the correct User_Stack");
      Check_Equal(Core_Locals(Core_Index).Hart_ID,
         Saved_Core.Hart_ID,
         "Saved core context must have the correct Hart_ID");
      Check_Equal(Core_Locals(Core_Index).Number,
         Saved_Core.Number,
         "Saved core context must have the correct core number");
   end Test_Save_Core_Context;

   procedure Register_Tests (T : in out Core_Context_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_Save_Core_Context'Access, "Test_Save_Core_Context");
   end Register_Tests;

   function Name (T : Core_Context_Test) return Message_String is
   begin
      return "Core_Context_Tests";
   end Name;

end Core_Context_Tests;
