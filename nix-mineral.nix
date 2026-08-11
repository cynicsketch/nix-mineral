# This file is part of nix-mineral (https://github.com/cynicsketch/nix-mineral/).
# Copyright (c) 2025 cynicsketch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This is the main module for nix-mineral, containing the default configuration.

{
  options,
  config,
  pkgs,
  lib,
  l,
  ...
}:

let
  cfg = config.nix-mineral;

  settingsModules =
    l.mkCategoryModules cfg.settings
      [
        ./settings/kernel
        ./settings/system
        ./settings/network
        ./settings/entropy
        ./settings/debug
        ./settings/etc
        ./settings/pam
        ./settings/misc
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };

  extrasModules =
    l.mkCategoryModules cfg.extras
      [
        ./extras/kernel
        ./extras/system
        ./extras/network
        ./extras/entropy
        ./extras/misc
        ./extras/tmpfiles
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };

  filesystemsModules =
    l.mkCategoryModules cfg.filesystems
      [
        ./filesystems/normal.nix
        ./filesystems/special.nix
      ]
      {
        inherit
          options
          config
          pkgs
          lib
          ;
      };

  kmodulesModules =
    l.mkCategoryModules cfg.kernel-modules
      [
        ./kernel-modules/load.nix
        ./kernel-modules/disable.nix
        ./kernel-modules/blacklist.nix
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
  imports = [
    (l.importModule ./presets { })
  ]
  ++ (l.mkCategoryImports settingsModules)
  ++ (l.mkCategoryImports extrasModules)
  ++ (l.mkCategoryImports filesystemsModules)
  ++ (l.mkCategoryImports kmodulesModules);

  options = {
    nix-mineral = {
      enable = l.mkEnableOption "the nix-mineral module";

      settings = l.mkCategoryOptions settingsModules;

      extras = l.mkCategoryOptions extrasModules;

      filesystems = l.mkCategoryOptions filesystemsModules;

      kernel-modules = l.mkCategoryOptions kmodulesModules;
    };
  };

  config = l.mkIf cfg.enable (
    l.mkMerge [
      (l.mkCategoryConfig settingsModules)
      (l.mkCategoryConfig extrasModules)
      (l.mkCategoryConfig filesystemsModules)
      (l.mkCategoryConfig kmodulesModules)
    ]
  );
}
