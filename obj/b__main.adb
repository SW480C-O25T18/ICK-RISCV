pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__main.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__main.adb");
pragma Suppress (Overflow_Check);

package body ada_main is



   procedure adainit is
   begin
      null;

   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_main");

   procedure main is
      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      adainit;
      Ada_Main_Program;
   end;

--  BEGIN Object file/option list
   --   /home/michael/capstoneProject/ironclad/obj/lib.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-alignment.o
   --   /home/michael/capstoneProject/ironclad/obj/arch.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-clocks.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-hooks.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-interrupts.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-context.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-power.o
   --   /home/michael/capstoneProject/ironclad/obj/config.o
   --   /home/michael/capstoneProject/ironclad/obj/cryptography.o
   --   /home/michael/capstoneProject/ironclad/obj/cryptography-chacha20.o
   --   /home/michael/capstoneProject/ironclad/obj/cryptography-md5.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-atomic.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-cmdline.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-time.o
   --   /home/michael/capstoneProject/ironclad/obj/memory.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-snippets.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-synchronization.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-mmu.o
   --   /home/michael/capstoneProject/ironclad/obj/networking.o
   --   /home/michael/capstoneProject/ironclad/obj/networking-arp.o
   --   /home/michael/capstoneProject/ironclad/obj/networking-ipv4.o
   --   /home/michael/capstoneProject/ironclad/obj/networking-ipv6.o
   --   /home/michael/capstoneProject/ironclad/obj/userland.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-memory_locations.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-console.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-netinter.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-streams.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-termios.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-uart.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-debug.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-messages.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-panic.o
   --   /home/michael/capstoneProject/ironclad/obj/devices.o
   --   /home/michael/capstoneProject/ironclad/obj/cryptography-random.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-shm.o
   --   /home/michael/capstoneProject/ironclad/obj/networking-interfaces.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-memory_failure.o
   --   /home/michael/capstoneProject/ironclad/obj/memory-physical.o
   --   /home/michael/capstoneProject/ironclad/obj/devices-loopback.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-fifo.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-futex.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-pty.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-socket.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-mac.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-local.o
   --   /home/michael/capstoneProject/ironclad/obj/ipc-filelock.o
   --   /home/michael/capstoneProject/ironclad/obj/scheduler.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-loader.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-process.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-syscall.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-elf.o
   --   /home/michael/capstoneProject/ironclad/obj/userland-oom_failure.o
   --   /home/michael/capstoneProject/ironclad/obj/vfs-dev.o
   --   /home/michael/capstoneProject/ironclad/obj/vfs-ext.o
   --   /home/michael/capstoneProject/ironclad/obj/vfs-fat.o
   --   /home/michael/capstoneProject/ironclad/obj/vfs.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-limine.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-cpu.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-dtb.o
   --   /home/michael/capstoneProject/ironclad/obj/lib-runtime.o
   --   /home/michael/capstoneProject/ironclad/obj/kernel_main.o
   --   /home/michael/capstoneProject/ironclad/obj/arch-entrypoint.o
   --   /home/michael/capstoneProject/ironclad/obj/main.o
   --   -L/home/michael/capstoneProject/ironclad/obj/
   --   -L/home/michael/capstoneProject/ironclad/obj/
   --   -L/home/michael/capstoneProject/ironclad/rtsdir/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
