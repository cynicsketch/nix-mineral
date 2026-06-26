{
  pkgs,
  nixosModule,
}:
# Ensure that preset loads with default preset enabled
pkgs.testers.runNixOSTest {
  name = "mineral-preset-default";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n net.ipv4.tcp_syncookies | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.tcp_rfc1337 | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.rp_filter | grep -qx 1")
    machine.succeed("sysctl -n kernel.sysrq | grep -qx 0")
  '';
}
