({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.software-choice.no-firewall.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Disable default firewall as chosen by nix-mineral.
    '';
  };

  config = mkIf config.nm-overrides.software-choice.no-firewall.enable {
    networking.firewall.enable = mkForce false;
  };
})