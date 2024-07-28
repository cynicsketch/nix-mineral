({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.hideproc-relaxed.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow processes that can ptrace a process to read its corresponding /proc
    information.
    '';
  };

  config = mkIf config.nm-overrides.desktop.hideproc-relaxed.enable {
    boot.specialFileSystems."/proc" = mkForce {
      fsType = "proc";
      device = "proc";
      options = [ "nosuid" "nodev" "noexec" "hidepid=4" "gid=proc" ];
    };
  };
})