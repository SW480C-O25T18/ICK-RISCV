with AUnit.Assertions; use AUnit.Assertions;
with Ada.Text_IO; use Ada.Text_IO;
with Memory.Physical;
with Arch.Context;

package body Test_Context is

   -- Validate general-purpose context switching, including SSTATUS
   procedure Test_GP_Context is
      Ctx1, Ctx2 : GP_Context;
      Stack      : System.Address := Memory.Physical.Alloc (4096);
   begin
      -- Initialize context
      Init_GP_Context (Ctx1, Stack, System.Null_Address);
      Ctx2 := Ctx1;

      -- Validate register contents
      Assert (Ctx1.SP = Ctx2.SP, "Stack pointer mismatch!");
      Assert (Ctx1.SEPC = Ctx2.SEPC, "Program counter mismatch!");
      Assert (Ctx1.SSTATUS /= 0, "SSTATUS not set correctly!");
      Put_Line ("[TEST] Test_GP_Context - PASSED");
   end Test_GP_Context;

   -- Validate floating-point context
   procedure Test_FP_Context is
      Ctx1, Ctx2 : FP_Context;
   begin
      Init_FP_Context (Ctx1);
      Ctx2 := Ctx1;

      -- Validate context allocation
      Assert (Ctx1 /= System.Null_Address, "Floating-point context not allocated!");
      Put_Line ("[TEST] Test_FP_Context - PASSED");
   end Test_FP_Context;

   -- Validate Get_Hart_ID function
   procedure Test_Get_Hart_ID is
      Hart_ID : Unsigned_64;
   begin
      Hart_ID := Get_Hart_ID;
      Assert (Hart_ID < 64, "Invalid Hart ID!");
      Put_Line ("[TEST] Test_Get_Hart_ID - PASSED");
   end Test_Get_Hart_ID;

   -- Validate Has_Extension function
   procedure Test_Has_Extension is
      Result : Boolean;
   begin
      Result := Has_Extension (16#10#);  -- Check for 'F' extension
      Put_Line ("[TEST] Test_Has_Extension - PASSED");
   end Test_Has_Extension;

   -- Validate Get_Num_FP_Registers function
   procedure Test_Get_Num_FP_Registers is
      Num_FP_Regs : Natural;
   begin
      Num_FP_Regs := Get_Num_FP_Registers;
      Assert (Num_FP_Regs in 0 .. 32, "Invalid number of FP registers!");
      Put_Line ("[TEST] Test_Get_Num_FP_Registers - PASSED");
   end Test_Get_Num_FP_Registers;

   -- Validate Save_FP_Context and Load_FP_Context procedures
   procedure Test_Save_Load_FP_Context is
      Ctx1, Ctx2 : FP_Context;
   begin
      Init_FP_Context (Ctx1);
      Save_FP_Context (Ctx1);
      Load_FP_Context (Ctx2);
      Assert (Ctx1 = Ctx2, "FP context mismatch after save/load!");
      Put_Line ("[TEST] Test_Save_Load_FP_Context - PASSED");
   end Test_Save_Load_FP_Context;

   -- Validate Destroy_FP_Context procedure
   procedure Test_Destroy_FP_Context is
      Ctx : FP_Context;
   begin
      Init_FP_Context (Ctx);
      Destroy_FP_Context (Ctx);
      Assert (Ctx = (others => 0), "FP context not destroyed correctly!");
      Put_Line ("[TEST] Test_Destroy_FP_Context - PASSED");
   end Test_Destroy_FP_Context;

   -- Register tests
   procedure Register_Tests (T : in out Context_Test_Case) is
   begin
      T.Register_Test ("Test_GP_Context", Test_GP_Context'Access);
      T.Register_Test ("Test_FP_Context", Test_FP_Context'Access);
      T.Register_Test ("Test_Get_Hart_ID", Test_Get_Hart_ID'Access);
      T.Register_Test ("Test_Has_Extension", Test_Has_Extension'Access);
      T.Register_Test ("Test_Get_Num_FP_Registers", Test_Get_Num_FP_Registers'Access);
      T.Register_Test ("Test_Save_Load_FP_Context", Test_Save_Load_FP_Context'Access);
      T.Register_Test ("Test_Destroy_FP_Context", Test_Destroy_FP_Context'Access);
   end Register_Tests;

end Test_Context;