({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.compatibility.binfmt-misc.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Reenable binfmt_misc.
    '';
  };

  config = mkIf config.nm-overrides.compatibility.binfmt-misc.enable {
    boot.kernel.sysctl."fs.binfmt_misc.status" = mkForce "1";
  };
})