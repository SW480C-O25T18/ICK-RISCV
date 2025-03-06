with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration; use AUnit.Test_Cases.Registration;
with Arch.Context;
with Arch.Interrupts; use Arch.Interrupts;
with Interfaces;         use Interfaces;
with Memory.Physical;
with System;
with AUnit; use AUnit;
with AUnit.Test_Cases; use AUnit.Test_Cases;

package body GP_Context_Tests is

   procedure Test_To_GP_Context_Type (T : in out Test_Case'Class) is
      Internal : Arch.Context.GP_Context_Type;
      Dummy_Frame : constant Frame :=
        (R0  => 0,
         R1  => 1,
         R2  => 16#1000#,  -- Example stack pointer.
         R3  => 3,
         R4  => 4,
         R5  => 5,
         R6  => 6,
         R7  => 7,
         R8  => 8,
         R9  => 9,
         R10 => 10,        -- Example return register.
         R11 => 11,
         R12 => 12,
         R13 => 13,
         R14 => 14,
         R15 => 15);
   begin
      Internal := Arch.Context.To_GP_Context_Type(Dummy_Frame);
      Check_Equal(16#1000#, Internal.SP, "SP from Frame.R2 should be 0x1000");
      Check_Equal(10, Internal.A0, "A0 from Frame.R10 should be 10");
      Check_True(Internal.SEPC /= 0, "SEPC must be nonzero");
      Check_True(Internal.SSTATUS /= 0, "SSTATUS must be nonzero");
   end Test_To_GP_Context_Type;

   procedure Test_To_Frame (T : in out Test_Case'Class) is
      Internal : Arch.Context.GP_Context_Type :=
         (SP      => 16#12345678#,
          SEPC    => 16#DEADBEEF#,
          SSTATUS => 16#CAFEBABE#,
          A0      => 16#ABCDEF00#);
      External : Frame;
   begin
      External := Arch.Context.To_Frame(Internal);
      Check_Equal(16#12345678#, External.R2, "External R2 must equal lower 32 bits of SP");
      Check_Equal(16#ABCDEF00#, External.R10, "External R10 must equal lower 32 bits of A0");
      Check_Equal(0, External.R0, "R0 should be zero");
      Check_Equal(0, External.R15, "R15 should be zero");
   end Test_To_Frame;

   procedure Test_Init_GP_Context (T : in out Test_Case'Class) is
      Ctx         : Arch.Context.GP_Context;
      Stack       : System.Address := Memory.Physical.Alloc(4096);
      Dummy_Start : constant System.Address := System.Address'Value(16#4000#);
      Internal    : Arch.Context.GP_Context_Type;
   begin
      Arch.Context.Init_GP_Context(Ctx, Stack, Dummy_Start);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Check_True(Internal.SP /= 0, "SP must be set by Init_GP_Context");
      Check_True(Internal.SEPC /= 0, "SEPC must be nonzero after init");
      Check_Equal(0, Internal.A0, "A0 should be initialized to zero");
   end Test_Init_GP_Context;

   procedure Test_Success_Fork_Result (T : in out Test_Case'Class) is
      Ctx         : Arch.Context.GP_Context;
      Stack       : System.Address := Memory.Physical.Alloc(4096);
      Dummy_Start : constant System.Address := System.Address'Value(16#5000#);
      Internal    : Arch.Context.GP_Context_Type;
      Old_SEPC    : Unsigned_64;
   begin
      Arch.Context.Init_GP_Context(Ctx, Stack, Dummy_Start);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Old_SEPC := Internal.SEPC;
      Arch.Context.Success_Fork_Result(Ctx);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Check_Equal(0, Internal.A0, "A0 should be set to 0 by Success_Fork_Result");
      Check_True(Internal.SEPC > Old_SEPC, "SEPC should be advanced after Success_Fork_Result");
   end Test_Success_Fork_Result;

   procedure Register_Tests (T : in out GP_Context_Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine(T, Test_To_GP_Context_Type'Access, "Test_To_GP_Context_Type");
      Register_Routine(T, Test_To_Frame'Access, "Test_To_Frame");
      Register_Routine(T, Test_Init_GP_Context'Access, "Test_Init_GP_Context");
      Register_Routine(T, Test_Success_Fork_Result'Access, "Test_Success_Fork_Result");
   end Register_Tests;

   overriding function Name (T : GP_Context_Test) return Message_String is
   begin
      return "GP_Context_Tests";
   end Name;

end GP_Context_Tests;
