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

{ inputs, ... }:

let
  l = inputs.nixpkgs.lib // builtins;

  sources = l.fromTOML (l.readFile ./sources.toml);

  fetchGhFile =
    {
      user,
      repo,
      rev,
      file,
      sha256,
      ...
    }:
    l.fetchurl {
      url = "https://raw.githubusercontent.com/${user}/${repo}/${rev}/${file}";
      inherit sha256;
    };

  # constructor to create a boolean option easily with a description and default value
  mkBoolOption =
    desc: bool:
    l.mkOption {
      default = bool;
      example = !bool;
      description = desc;
      type = l.types.bool;
    };

  # import wrapper to pass extra args to a module
  # used to pass the `l` variable to every module, and used in the importCategoryModule function to pass parentCfg and cfg.
  importModule =
    path: extraArgs: # `extraArgs` is a attrset that can contain any additional arguments to pass to the module
    (
      {
        lib,
        config,
        options,
        pkgs,
        ...
      }:
      ((import path) (
        {
          inherit
            lib
            config
            options
            pkgs
            ;
          l = l // {
            # ugly, dont know another way to do this
            inherit
              sources
              fetchGhFile
              mkBoolOption
              importModule
              importCategoryModule
              mkCategoryModules
              mkCategorySubmodule
              mkCategoryConfig
              ;
          };
        }
        // extraArgs
      ))
    );

  # import a module using `importModule` and adds the args `parentCfg` and `cfg` to the module
  # `categoryConfig` is the config for the category the module belongs to, ex: config.nix-mineral.settings.kernel
  # `path` is the path to the module, ex: ./a-kernel-module.nix
  # `args` are the default arguments to pass to the module, needs to be: { inherit options config pkgs lib; }
  # ---
  # `parentCfg` is just the `categoryConfig` passed to the module
  # `cfg` is the child of parentCfg that has the base name of the path (without the .nix extension if any)
  importCategoryModule =
    categoryConfig: path: args:
    (
      (importModule path (
        let
          pathBaseName = l.baseNameOf path;
        in
        {
          # pass the category config to the module
          parentCfg = categoryConfig;
          # pass the path base name as a config attribute
          # remove .nix extension if present
          cfg =
            categoryConfig."${
              if (l.hasSuffix ".nix" pathBaseName) then
                l.substring 0 (l.stringLength pathBaseName - 4) pathBaseName
              else
                pathBaseName
            }";
        }
      ))
      args
    );

  # import many modules with `importCategoryModule` and creates a list with the results
  # `categoryConfig` is the config for the category the module belongs to, ex: config.nix-mineral.settings.kernel
  # `paths` is a list of paths to the modules, ex: [ ./a-kernel-module.nix ./another-kernel-module.nix ]
  # `args` are the default arguments to pass to the module, needs to be: { inherit options config pkgs lib; }
  mkCategoryModules =
    categoryConfig: paths: args:
    l.map (path: (importCategoryModule categoryConfig path args)) paths;

  # create a submodule type for a list of categoryModules created with `mkCategoryModules`
  mkCategorySubmodule =
    modules:
    (l.types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = l.map (module: {
        inherit (module) options;
      }) modules;
    });

  # create a config for a list of categoryModules created with `mkCategoryModules`
  # use this to define a `config = ...` attrset
  mkCategoryConfig = modules: (l.mkMerge (l.map (module: module.config) modules));
in
{
  flake.lib = {
    inherit
      sources
      fetchGhFile
      mkBoolOption
      importModule
      importCategoryModule
      mkCategoryModules
      mkCategorySubmodule
      mkCategoryConfig
      ;
  };
}
