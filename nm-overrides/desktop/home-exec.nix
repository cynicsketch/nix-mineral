({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.home-exec.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow programs to execute in /home.
    '';
  };

  config = mkIf config.nm-overrides.desktop.home-exec.enable {
    fileSystems."/home" = mkForce {
      device = "/home";
      options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
    };
  };
})