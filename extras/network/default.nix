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
        ./tcp-window-scaling.nix
        ./bluetooth-kmodules.nix
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
    network = l.mkOption {
      description = ''
        Extra settings for the network.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
