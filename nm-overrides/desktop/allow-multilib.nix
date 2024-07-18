({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.allow-multilib.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable support for 32 bit applications.
    '';
  };

  config = mkIf config.nm-overrides.desktop.allow-multilib.enable {
    boot.kernelParams = mkOverride 100 [ ("ia32_emulation=1") ];
  };
})