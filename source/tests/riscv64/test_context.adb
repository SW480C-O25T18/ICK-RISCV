with AUnit.Assertions;
with AUnit.Test_Cases.Registration;
with Arch.Context;
with System;
with Memory.Physical;
with Ada.Text_IO;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package body Test_Context is

   use AUnit.Assertions;

   -- Test General-Purpose Context Initialization
   procedure Test_Init_GP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : GP_Context;
      Stack : System.Address := Memory.Physical.Alloc (4096);
   begin
      Init_GP_Context (Ctx, Stack, System.Null_Address);
      Assert (Ctx.SP /= 0, "Stack pointer should not be zero!");
      Assert (Ctx.SEPC = 0, "Program counter should start at zero!");
   end Test_Init_GP_Context;

   -- Test General-Purpose Context Loading
   procedure Test_Load_GP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : GP_Context;
   begin
      Init_GP_Context (Ctx, Memory.Physical.Alloc (4096), System.Null_Address);
      -- No direct way to verify `sret`, but we can check CSR manipulation indirectly.
      Load_GP_Context (Ctx);
      -- Ensure function does not return unexpectedly
   end Test_Load_GP_Context;

   -- Test Multi-Core Core Context Saving
   procedure Test_Save_Core_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : Core_Context;
   begin
      Save_Core_Context (Ctx);
      Assert (Ctx >= 0, "Saved core context should be valid!");
   end Test_Save_Core_Context;

   -- Test Success Fork Result
   procedure Test_Success_Fork_Result (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : GP_Context;
   begin
      Init_GP_Context (Ctx, Memory.Physical.Alloc (4096), System.Null_Address);
      Success_Fork_Result (Ctx);
      Assert (Ctx.SEPC = 0, "SEPC should be 0 after fork!");
      Assert (Ctx.A0 = 0, "Child process should return 0 in A0!");
   end Test_Success_Fork_Result;

   -- Test Floating-Point Context Initialization
   procedure Test_Init_FP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Assert (Ctx /= System.Null_Address, "Floating-point context should be allocated!");
   end Test_Init_FP_Context;

   -- Test Floating-Point Context Saving
   procedure Test_Save_FP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Save_FP_Context (Ctx);
   end Test_Save_FP_Context;

   -- Test Floating-Point Context Loading
   procedure Test_Load_FP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Load_FP_Context (Ctx);
   end Test_Load_FP_Context;

   -- Test Floating-Point Context Destruction
   procedure Test_Destroy_FP_Context (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Destroy_FP_Context (Ctx);
      Assert (Ctx = System.Null_Address, "FP Context should be NULL after destruction!");
   end Test_Destroy_FP_Context;

   -- Test Hart ID Retrieval
   procedure Test_Get_Hart_ID (T : in out AUnit.Test_Cases.Test_Case'Class) is
      Hart : Unsigned_64;
   begin
      Hart := Get_Hart_ID;
      Assert (Hart < 64, "Hart ID should be valid (less than 64)!");
   end Test_Get_Hart_ID;

   -- Test CPU Extension Checking
   procedure Test_Has_Extension (T : in out AUnit.Test_Cases.Test_Case'Class) is
   begin
      Assert (Has_Extension (16#1#) = (Get_CSR (16#F11#) and 16#1# /= 0), "Extension check failed!");
   end Test_Has_Extension;

   -- Register all test cases
   overriding procedure Register_Tests (T : in out Test_Context) is
   begin
      Register_Routine (T, Test_Init_GP_Context'Access, "Test_Init_GP_Context");
      Register_Routine (T, Test_Load_GP_Context'Access, "Test_Load_GP_Context");
      Register_Routine (T, Test_Save_Core_Context'Access, "Test_Save_Core_Context");
      Register_Routine (T, Test_Success_Fork_Result'Access, "Test_Success_Fork_Result");
      Register_Routine (T, Test_Init_FP_Context'Access, "Test_Init_FP_Context");
      Register_Routine (T, Test_Save_FP_Context'Access, "Test_Save_FP_Context");
      Register_Routine (T, Test_Load_FP_Context'Access, "Test_Load_FP_Context");
      Register_Routine (T, Test_Destroy_FP_Context'Access, "Test_Destroy_FP_Context");
      Register_Routine (T, Test_Get_Hart_ID'Access, "Test_Get_Hart_ID");
      Register_Routine (T, Test_Has_Extension'Access, "Test_Has_Extension");
   end Register_Tests;

   overriding function Name (T : Test_Context) return Test_String is
   begin
      return Format ("Context Tests");
   end Name;
end Test_Context;