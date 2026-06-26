{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-settings-network";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings.network = {
      syncookies = true;
      rfc1337 = true;
      source-route = false;
      rp-filter = true;
      log-martians = true;
      shared-media = false;
      ip-forwarding = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n net.ipv4.tcp_syncookies | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.tcp_rfc1337 | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.accept_source_route | grep -qx 0")
    machine.succeed("sysctl -n net.ipv6.conf.all.accept_source_route | grep -qx 0")
    machine.succeed("sysctl -n net.ipv4.conf.all.rp_filter | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.log_martians | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.shared_media | grep -qx 0")
    machine.succeed("sysctl -n net.ipv4.ip_forward | grep -qx 0")
  '';
}
