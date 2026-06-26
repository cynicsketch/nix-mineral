{
  pkgs,
  nixosModule,
}:
# Check for kernel params
pkgs.testers.runNixOSTest {
  name = "mineral-settings-kernel";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings.kernel = {
      restrict-bpf = true;
      harden-bpf = true;
      restrict-line-disciplines = true;
      tiocsti = false;
      sysrq = "off";
      kexec = false;
      io-uring = false;
      bdev-write-mount = false;
      vsyscall = false;
      slab-merging = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n kernel.unprivileged_bpf_disabled | grep -qx 1")
    machine.succeed("sysctl -n net.core.bpf_jit_harden | grep -qx 2")
    machine.succeed("sysctl -n dev.tty.ldisc_autoload | grep -qx 0")
    machine.succeed("sysctl -n dev.tty.legacy_tiocsti | grep -qx 0")
    machine.succeed("sysctl -n kernel.sysrq | grep -qx 0")
    machine.succeed("sysctl -n kernel.kexec_load_disabled | grep -qx 1")
    machine.succeed("sysctl -n kernel.io_uring_disabled | grep -qx 2")
    machine.succeed("grep -q bdev_allow_write_mounted=0 /proc/cmdline")
    machine.succeed("grep -q vsyscall=none /proc/cmdline")
    machine.succeed("grep -q slab_nomerge /proc/cmdline")
  '';
}
