({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.performance.no-pti.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable page table isolation.
    '';
  };

  config = mkIf config.nm-overrides.performance.no-pti.enable {
    boot.kernelParams = mkOverride 100 [ ("pti=off") ];
  };
})