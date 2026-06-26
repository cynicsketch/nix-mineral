{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-extras-usbguard";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.extras.misc.usbguard = {
      enable = true;
      whitelist-at-boot = true;
    };
  };

  testScript = ''
    machine.wait_for_unit("usbguard.service")
  '';
}
