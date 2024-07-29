({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.disable-modules.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable loading kernel modules.
    '';
  };

  config = mkIf config.nm-overrides.security.disable-modules.enable {
    boot.kernel.sysctl."kernel.modules_disabled" = mkForce "1";
  };
})