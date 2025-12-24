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
in
{
  imports = [
    (l.importModule ./presets { })
  ];

  options = {
    nix-mineral = {
      enable = l.mkEnableOption "the nix-mineral module";

      settings = l.mkOption {
        description = ''
          nix-mineral settings.
        '';
        default = { };
        type = l.mkCategorySubmodule settingsModules;
      };

      extras = l.mkOption {
        description = ''
          Extra options that are not part of the main configuration.
        '';
        default = { };
        type = l.mkCategorySubmodule extrasModules;
      };

      filesystems = l.mkOption {
        description = ''
          Utility for hardening filesystems and special filesystems.
        '';
        default = { };
        type = l.mkCategorySubmodule filesystemsModules;
      };
    };
  };

  config = l.mkIf cfg.enable (
    l.mkMerge [
      (l.mkCategoryConfig settingsModules)
      (l.mkCategoryConfig extrasModules)
      (l.mkCategoryConfig filesystemsModules)
    ]
  );
}
