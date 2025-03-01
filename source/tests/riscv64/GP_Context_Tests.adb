with AUnit.Framework;
with Arch.Context;
with Arch.Interrupts; use Arch.Interrupts;
with Interfaces;         use Interfaces;

procedure GP_Context_Tests is

   package Test is new AUnit.Framework.Test_Case ("GP_Context_Tests");

   -- A constant dummy Frame with known values for testing.
   Dummy_Frame : constant Frame :=
     (R0  => 0,
      R1  => 1,
      R2  => 16#1000#,  -- Stack pointer value for testing.
      R3  => 3,
      R4  => 4,
      R5  => 5,
      R6  => 6,
      R7  => 7,
      R8  => 8,
      R9  => 9,
      R10 => 10,       -- Return register value.
      R11 => 11,
      R12 => 12,
      R13 => 13,
      R14 => 14,
      R15 => 15);

begin
   Test ("To_GP_Context_Type") is
      declare
         Internal : Arch.Context.GP_Context_Type :=
                      Arch.Context.To_GP_Context_Type (Dummy_Frame);
      begin
         Test.Check_Equal (16#1000#, Internal.SP, "SP from Frame.R2 should be 0x1000");
         Test.Check_Equal (10, Internal.A0, "A0 from Frame.R10 should be 10");
         -- SEPC and SSTATUS are read from hardware; we check that they are nonzero.
         Test.Check_True (Internal.SEPC /= 0, "SEPC must be nonzero");
         Test.Check_True (Internal.SSTATUS /= 0, "SSTATUS must be nonzero");
      end;

   Test ("To_Frame") is
      declare
         Internal : Arch.Context.GP_Context_Type :=
                      (SP      => 16#12345678#,
                       SEPC    => 16#DEADBEEF#,
                       SSTATUS => 16#CAFEBABE#,
                       A0      => 16#ABCDEF00#);
         External : Frame := Arch.Context.To_Frame (Internal);
      begin
         Test.Check_Equal (16#12345678#, External.R2, "R2 must be lower 32 bits of SP");
         Test.Check_Equal (16#ABCDEF00#, External.R10, "R10 must be lower 32 bits of A0");
         Test.Check_Equal (0, External.R0, "R0 should be zero");
         Test.Check_Equal (0, External.R15, "R15 should be zero");
      end;

   Test.Run;
end GP_Context_Tests;
