({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.allow-unprivileged-userns.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow unprivileged userns.
    '';
  };

  config = mkIf config.nm-overrides.desktop.allow-unprivileged-userns.enable {
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = mkForce "1";
  };
})