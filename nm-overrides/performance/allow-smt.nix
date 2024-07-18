({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.performance.allow-smt.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable symmetric multithreading.
    '';
  };

  config = mkIf config.nm-overrides.performance.allow-smt.enable {
    boot.kernelParams = mkOverride 100 [ ("mitigations=auto") ];
  };
})