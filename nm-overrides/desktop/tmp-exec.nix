({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.tmp-exec.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow executing programs in /tmp.
    '';
  };

  config = mkIf config.nm-overrides.desktop.tmp-exec.enable {
    fileSystems."/tmp" = mkForce {
      device = "/tmp";
      options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
    };
  };
})