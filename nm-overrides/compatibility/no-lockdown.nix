({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.no-lockdown.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable Linux Kernel Lockdown.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.no-lockdown.enable {
    boot.kernelParams = mkOverride 100 [ ("lockdown=") ];
  };
})