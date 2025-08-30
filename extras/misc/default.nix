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
        ./doas-sudo-wrapper.nix
        ./replace-sudo-with-doas.nix
        ./usbguard.nix
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
    misc = l.mkOption {
      description = ''
        Extra misc settings.
        Most of those are relatively opinionated additional software.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
