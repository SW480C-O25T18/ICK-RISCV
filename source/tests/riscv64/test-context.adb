with AUnit.Assertions;
with AUnit.Test_Fixtures;
with Arch.Context;
with System;
with Memory.Physical;
with Ada.Text_IO;

package body Test_Context is

   use AUnit.Assertions;
   use AUnit.Test_Fixtures;

   -- Test General-Purpose Context Initialization
   procedure Test_Init_GP_Context is
      Ctx : GP_Context;
      Stack : System.Address := Memory.Physical.Alloc (4096);
   begin
      Init_GP_Context (Ctx, Stack, System.Null_Address);
      Assert (Ctx.SP /= 0, "Stack pointer should not be zero!");
      Assert (Ctx.SEPC = 0, "Program counter should start at zero!");
   end Test_Init_GP_Context;

   -- Test General-Purpose Context Loading
   procedure Test_Load_GP_Context is
      Ctx : GP_Context;
   begin
      Init_GP_Context (Ctx, Memory.Physical.Alloc (4096), System.Null_Address);
      -- No direct way to verify `sret`, but we can check CSR manipulation indirectly.
      Load_GP_Context (Ctx);
      -- Ensure function does not return unexpectedly
   end Test_Load_GP_Context;

   -- Test Multi-Core Core Context Saving
   procedure Test_Save_Core_Context is
      Ctx : Core_Context;
   begin
      Save_Core_Context (Ctx);
      Assert (Ctx >= 0, "Saved core context should be valid!");
   end Test_Save_Core_Context;

   -- Test Success Fork Result
   procedure Test_Success_Fork_Result is
      Ctx : GP_Context;
   begin
      Init_GP_Context (Ctx, Memory.Physical.Alloc (4096), System.Null_Address);
      Success_Fork_Result (Ctx);
      Assert (Ctx.SEPC = 0, "SEPC should be 0 after fork!");
      Assert (Ctx.A0 = 0, "Child process should return 0 in A0!");
   end Test_Success_Fork_Result;

   -- Test Floating-Point Context Initialization
   procedure Test_Init_FP_Context is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Assert (Ctx /= System.Null_Address, "Floating-point context should be allocated!");
   end Test_Init_FP_Context;

   -- Test Floating-Point Context Saving
   procedure Test_Save_FP_Context is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Save_FP_Context (Ctx);
   end Test_Save_FP_Context;

   -- Test Floating-Point Context Loading
   procedure Test_Load_FP_Context is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Load_FP_Context (Ctx);
   end Test_Load_FP_Context;

   -- Test Floating-Point Context Destruction
   procedure Test_Destroy_FP_Context is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Destroy_FP_Context (Ctx);
      Assert (Ctx = System.Null_Address, "FP Context should be NULL after destruction!");
   end Test_Destroy_FP_Context;

   -- Test Hart ID Retrieval
   procedure Test_Get_Hart_ID is
      Hart : Unsigned_64;
   begin
      Hart := Get_Hart_ID;
      Assert (Hart < 64, "Hart ID should be valid (less than 64)!");
   end Test_Get_Hart_ID;

   -- Test CPU Extension Checking
   procedure Test_Has_Extension is
   begin
      Assert (Has_Extension (16#1#) = (Get_CSR (16#F11#) and 16#1# /= 0), "Extension check failed!");
   end Test_Has_Extension;

   -- Register all test cases
   procedure Register_Tests (T : in out Context_Test_Case) is
   begin
      T.Register_Test ("Test_Init_GP_Context", Test_Init_GP_Context'Access);
      T.Register_Test ("Test_Load_GP_Context", Test_Load_GP_Context'Access);
      T.Register_Test ("Test_Save_Core_Context", Test_Save_Core_Context'Access);
      T.Register_Test ("Test_Success_Fork_Result", Test_Success_Fork_Result'Access);
      T.Register_Test ("Test_Init_FP_Context", Test_Init_FP_Context'Access);
      T.Register_Test ("Test_Save_FP_Context", Test_Save_FP_Context'Access);
      T.Register_Test ("Test_Load_FP_Context", Test_Load_FP_Context'Access);
      T.Register_Test ("Test_Destroy_FP_Context", Test_Destroy_FP_Context'Access);
      T.Register_Test ("Test_Get_Hart_ID", Test_Get_Hart_ID'Access);
      T.Register_Test ("Test_Has_Extension", Test_Has_Extension'Access);
   end Register_Tests;

end Test_Context;
