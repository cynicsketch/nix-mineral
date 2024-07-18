({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.allow-unsigned-modules.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow loading unsigned kernel modules.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.allow-unsigned-modules.enable {
    boot.kernelParams = mkOverride 100 [ ("module.sig_enforce=0") ];
  };
})