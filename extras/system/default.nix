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
        ./lock-root.nix
        ./minimize-swapping.nix
        ./sysrq-sak.nix
        ./hardened-malloc.nix
        ./secure-chrony.nix
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
        Extra settings for the system.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
