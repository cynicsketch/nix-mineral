{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-extras-chrony";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.extras.system.secure-chrony = true;
  };

  testScript = ''
    machine.wait_for_unit("chronyd.service")
    machine.fail("systemctl is-active --quiet systemd-timesyncd.service")
  '';
}
