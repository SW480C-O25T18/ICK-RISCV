-- Composition package:
with AUnit; use AUnit;
package Composite_Suite is
   function Suite return Test_Suites.Access_Test_Suite;
end Composite_Suite;