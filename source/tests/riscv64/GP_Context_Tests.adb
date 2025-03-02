with AUnit.Framework;
with Arch.Context;
with Arch.Interrupts; use Arch.Interrupts;
with Interfaces;         use Interfaces;
with Memory.Physical;
with System;

procedure GP_Context_Tests is

   package Test is new AUnit.Framework.Test_Case("GP_Context_Tests");

   -- Dummy_Frame: a constant Frame with known values for testing conversion routines.
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

   -------------------------------------------------------------------
   -- Test case for converting an external Frame to an internal context.
   -------------------------------------------------------------------
   procedure Test_To_GP_Context_Type is
      Internal : Arch.Context.GP_Context_Type;
   begin
      Internal := Arch.Context.To_GP_Context_Type(Dummy_Frame);
      Test.Check_Equal(16#1000#, Internal.SP, "SP from Frame.R2 should be 0x1000");
      Test.Check_Equal(10, Internal.A0, "A0 from Frame.R10 should be 10");
      -- SEPC and SSTATUS are fetched via CSR; check that they are nonzero.
      Test.Check_True(Internal.SEPC /= 0, "SEPC must be nonzero");
      Test.Check_True(Internal.SSTATUS /= 0, "SSTATUS must be nonzero");
   end Test_To_GP_Context_Type;

   -------------------------------------------------------------------
   -- Test case for converting an internal context back to an external Frame.
   -------------------------------------------------------------------
   procedure Test_To_Frame is
      Internal : Arch.Context.GP_Context_Type :=
         (SP      => 16#12345678#,
          SEPC    => 16#DEADBEEF#,
          SSTATUS => 16#CAFEBABE#,
          A0      => 16#ABCDEF00#);
      External : Frame;
   begin
      External := Arch.Context.To_Frame(Internal);
      Test.Check_Equal(16#12345678#, External.R2, "External R2 must equal lower 32 bits of SP");
      Test.Check_Equal(16#ABCDEF00#, External.R10, "External R10 must equal lower 32 bits of A0");
      Test.Check_Equal(0, External.R0, "R0 should be zero");
      Test.Check_Equal(0, External.R15, "R15 should be zero");
   end Test_To_Frame;

   -------------------------------------------------------------------
   -- Test case for initializing GP context.
   -------------------------------------------------------------------
   procedure Test_Init_GP_Context is
      Ctx         : GP_Context;
      Stack       : System.Address := Memory.Physical.Alloc(4096);
      Dummy_Start : constant System.Address := System.Address'Value(16#4000#);
      Internal    : Arch.Context.GP_Context_Type;
   begin
      Init_GP_Context(Ctx, Stack, Dummy_Start);
      Internal := Arch.Context.To_GP_Context_Type(Ctx);
      Test.Check_True(Internal.SP /= 0, "SP must be set by Init_GP_Context");
      Test.Check_True(Internal.SEPC /= 0, "SEPC must be nonzero after init");
      Test.Check_Equal(0, Internal.A0, "A0 should be initialized to zero");
   end Test_Init_GP_Context;

begin
   Test.Register(Test_To_GP_Context_Type'Access);
   Test.Register(Test_To_Frame'Access);
   Test.Register(Test_Init_GP_Context'Access);
   Test.Run;
end GP_Context_Tests;
