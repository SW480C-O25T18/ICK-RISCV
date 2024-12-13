pragma Warnings (Off);
pragma Ada_95;
pragma Restrictions (No_Exception_Propagation);
with System;
package ada_main is


   GNAT_Version : constant String :=
                    "GNAT Version: 14.2.0" & ASCII.NUL;
   pragma Export (C, GNAT_Version, "__gnat_version");

   GNAT_Version_Address : constant System.Address := GNAT_Version'Address;
   pragma Export (C, GNAT_Version_Address, "__gnat_version_address");

   Ada_Main_Program_Name : constant String := "_ada_main" & ASCII.NUL;
   pragma Export (C, Ada_Main_Program_Name, "__gnat_ada_main_program_name");

   procedure adainit;
   pragma Export (C, adainit, "adainit");

   procedure main;
   pragma Export (C, main, "main");

   --  BEGIN ELABORATION ORDER
   --  ada%s
   --  ada.characters%s
   --  ada.characters.latin_1%s
   --  interfaces%s
   --  interfaces.c%s
   --  system%s
   --  system.machine_code%s
   --  system.storage_elements%s
   --  system.storage_elements%b
   --  system.unsigned_types%s
   --  lib%s
   --  lib%b
   --  lib.alignment%s
   --  lib.alignment%b
   --  arch%s
   --  arch.clocks%s
   --  arch.clocks%b
   --  arch.hooks%s
   --  arch.hooks%b
   --  arch.interrupts%s
   --  arch.context%s
   --  arch.context%b
   --  arch.power%s
   --  arch.power%b
   --  config%s
   --  cryptography%s
   --  cryptography.chacha20%s
   --  cryptography.chacha20%b
   --  cryptography.md5%s
   --  cryptography.md5%b
   --  ipc%s
   --  lib.atomic%s
   --  lib.cmdline%s
   --  lib.cmdline%b
   --  lib.time%s
   --  lib.time%b
   --  memory%s
   --  arch.snippets%s
   --  arch.snippets%b
   --  lib.synchronization%s
   --  lib.synchronization%b
   --  arch.mmu%s
   --  arch.mmu%b
   --  networking%s
   --  networking%b
   --  networking.arp%s
   --  networking.arp%b
   --  networking.ipv4%s
   --  networking.ipv4%b
   --  networking.ipv6%s
   --  networking.ipv6%b
   --  userland%s
   --  userland.memory_locations%s
   --  cryptography.random%s
   --  devices%s
   --  arch.debug%s
   --  devices.console%s
   --  devices.console%b
   --  devices.loopback%s
   --  devices.netinter%s
   --  devices.streams%s
   --  devices.streams%b
   --  devices.termios%s
   --  devices.uart%s
   --  devices.uart%b
   --  arch.debug%b
   --  ipc.fifo%s
   --  ipc.futex%s
   --  ipc.pty%s
   --  ipc.shm%s
   --  ipc.socket%s
   --  lib.messages%s
   --  lib.messages%b
   --  lib.panic%s
   --  lib.panic%b
   --  devices%b
   --  memory.physical%s
   --  cryptography.random%b
   --  ipc.shm%b
   --  networking.interfaces%s
   --  networking.interfaces%b
   --  userland.memory_failure%s
   --  userland.memory_failure%b
   --  userland.oom_failure%s
   --  memory.physical%b
   --  vfs%s
   --  userland.elf%s
   --  scheduler%s
   --  devices.loopback%b
   --  ipc.fifo%b
   --  ipc.futex%b
   --  ipc.pty%b
   --  ipc.socket%b
   --  userland.mac%s
   --  userland.mac%b
   --  userland.process%s
   --  arch.local%s
   --  arch.local%b
   --  ipc.filelock%s
   --  ipc.filelock%b
   --  scheduler%b
   --  userland.loader%s
   --  userland.loader%b
   --  userland.process%b
   --  userland.syscall%s
   --  userland.syscall%b
   --  userland.elf%b
   --  userland.oom_failure%b
   --  vfs.dev%s
   --  vfs.dev%b
   --  vfs.ext%s
   --  vfs.ext%b
   --  vfs.fat%s
   --  vfs.fat%b
   --  vfs%b
   --  arch.limine%s
   --  arch.limine%b
   --  arch.cpu%s
   --  arch.cpu%b
   --  arch.dtb%s
   --  arch.dtb%b
   --  lib.runtime%s
   --  lib.runtime%b
   --  kernel_main%s
   --  kernel_main%b
   --  arch.entrypoint%s
   --  arch.entrypoint%b
   --  main%b
   --  END ELABORATION ORDER

end ada_main;
