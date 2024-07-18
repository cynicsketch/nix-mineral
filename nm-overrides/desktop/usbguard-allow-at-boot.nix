({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.usbguard-allow-at-boot.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Automatically whitelist all USB devices at boot in USBGuard.
    '';
  };

  config = mkIf config.nm-overrides.desktop.usbguard-allow-at-boot.enable {
    services.usbguard.presentDevicePolicy = mkForce "allow"; 
  };
})