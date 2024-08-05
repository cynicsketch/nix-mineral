({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.minimum-swappiness.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reduce frequency of swapping to bare minimum.
    '';
  };

  config = mkIf config.nm-overrides.security.minimum-swappiness.enable {
    boot.kernel.sysctl."vm.swappiness" = mkForce "1";
  };
})