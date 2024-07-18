({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.nix-allow-allow-users.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Allow all users to use nix.
    '';
  };

  config = mkIf config.nm-overrides.desktop.nix-allow-allow-users.enable {
    nix.settings.allowed-users = mkForce [ ("*") ];
  };
})