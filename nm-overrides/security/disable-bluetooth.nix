({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.disable-bluetooth.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable bluetooth completely.
    '';
  };

  config = mkIf config.nm-overrides.security.disable-bluetooth.enable {
    environment.etc."modprobe.d/nm-disable-bluetooth.conf" = {
      text = ''
        install bluetooth /bin/disabled-bluetooth-by-security-misc
        install btusb /bin/disabled-bluetooth-by-security-misc
      '';
    };
  };
})