({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.security.lock-root.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Lock the root user.
    '';
  };

  config = mkIf config.nm-overrides.security.lock-root.enable {
    users = { users = { root = { hashedPassword = "!"; }; }; };
  };
})