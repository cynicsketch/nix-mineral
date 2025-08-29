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
