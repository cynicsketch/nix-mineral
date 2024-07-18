({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.usbguard-disable.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable USBGuard entirely. 
    '';
  };

  config = mkIf config.nm-overrides.desktop.usbguard-disable.enable {
    services.usbguard.enable = mkForce false;
  };
})