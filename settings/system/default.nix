{
  options,
  config,
  pkgs,
  lib,
  l,
  cfg,
  ...
}:

let
  categoryModules =
    l.mkCategoryModules cfg
      [
        ./multilib.nix
        ./unprivileged-userns.nix
        ./nix-allow-only-wheel.nix
        ./lock-root.nix
        ./minimize-swapping.nix
        ./sysrq-sak.nix
        ./hardened-malloc.nix
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };
in
{
  options = {
    system = l.mkOption {
      description = ''
        Settings for the system.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
