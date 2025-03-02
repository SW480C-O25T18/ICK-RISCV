with AUnit.Test_Cases;
with Arch.Context; use Arch.Context;
with Arch.CPU;      use Arch.CPU;

procedure Core_Context_Tests is

   package Test is new AUnit.Test_Cases.Test_Case("Core_Context_Tests");

   -------------------------------------------------------------------
   -- Test that Save_Core_Context saves the correct per-core state.
   -------------------------------------------------------------------
   procedure Test_Save_Core_Context is
      Saved_Core   : Core_Context;
      Current_Hart : Unsigned_64;
      Core_Index   : Positive;
   begin
      Current_Hart := Get_Hart_ID;
      Core_Index   := Positive(Integer(Current_Hart) + 1);
      pragma Assert(Core_Index <= Core_Count, "Test: Core index out of bounds");
      Save_Core_Context(Saved_Core);
      Test.Check_Equal(Core_Locals(Core_Index).User_Stack,
                  Saved_Core.User_Stack,
                  "Saved core context must have the correct User_Stack");
      Test.Check_Equal(Core_Locals(Core_Index).Hart_ID,
                  Saved_Core.Hart_ID,
                  "Saved core context must have the correct Hart_ID");
      Test.Check_Equal(Core_Locals(Core_Index).Number,
                  Saved_Core.Number,
                  "Saved core context must have the correct core number");
   end Test_Save_Core_Context;

begin
   Test.Register(Test_Save_Core_Context'Access);
   Test.Run;
end Core_Context_Tests;
