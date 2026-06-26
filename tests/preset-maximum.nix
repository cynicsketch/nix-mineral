{
  pkgs,
  nixosModule,
}:
# Ensure that preset loads with maximum preset enabled
pkgs.testers.runNixOSTest {
  name = "mineral-preset-maximum";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.preset = "maximum";
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n kernel.sysrq | grep -qx 4")
    machine.succeed("sysctl -n kernel.yama.ptrace_scope | grep -qx 3")
    machine.wait_for_unit("chronyd.service")
    machine.wait_for_unit("usbguard.service")
  '';
}
