({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.disable-intelme-kmodules.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable Intel ME related kernel modules and partially disable ME interface.
    '';
  };

  config = mkIf config.nm-overrides.security.disable-intelme-kmodules.enable {
    environment.etc."modprobe.d/nm-disable-intelme-kmodules.conf" = {
      text = ''
          install mei /usr/bin/disabled-intelme-by-security-misc
          install mei-gsc /usr/bin/disabled-intelme-by-security-misc
          install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
          install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
          install mei-me /usr/bin/disabled-intelme-by-security-misc
          install mei_phy /usr/bin/disabled-intelme-by-security-misc
          install mei_pxp /usr/bin/disabled-intelme-by-security-misc
          install mei-txe /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
          install mei_wdt /usr/bin/disabled-intelme-by-security-misc
          install microread_mei /usr/bin/disabled-intelme-by-security-misc
      '';
    };
  };
})