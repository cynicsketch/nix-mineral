({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.var-lib-exec.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow executing programs in /var/lib.
    '';
  };

  config = mkIf config.nm-overrides.desktop.var-lib-exec.enable {
    fileSystems."/var/lib" = mkForce { 
      device = "/var/lib";
      options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
    };
  };
})