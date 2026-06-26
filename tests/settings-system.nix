{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-settings-system";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings = {
      system = {
        file-protection = true;
        link-protection = true;
        lower-address-mmap = false;
        yama = "relaxed";
      };
      debug = {
        dmesg-restrict = true;
        kptr-restrict = true;
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n fs.protected_regular | grep -qx 2")
    machine.succeed("sysctl -n fs.protected_fifos | grep -qx 2")
    machine.succeed("sysctl -n fs.protected_hardlinks | grep -qx 1")
    machine.succeed("sysctl -n fs.protected_symlinks | grep -qx 1")
    machine.succeed("sysctl -n vm.mmap_min_addr | grep -qx 65536")
    machine.succeed("sysctl -n kernel.yama.ptrace_scope | grep -qx 1")
    machine.succeed("sysctl -n kernel.dmesg_restrict | grep -qx 1")
    machine.succeed("sysctl -n kernel.kptr_restrict | grep -qx 2")
  '';
}
