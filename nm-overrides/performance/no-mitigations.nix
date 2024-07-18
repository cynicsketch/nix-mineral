({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.performance.no-mitigations.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable all CPU vulnerability mitigations.
    '';
  };

  config = mkIf config.nm-overrides.performance.no-mitigations.enable {
    boot.kernelParams = mkOverride 100 [ ("mitigations=off") ];
  };
})