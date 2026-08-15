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

  # constructor to create a deprecated option, forcing the default value to be null.
  # intended to be used with `mkDeprecatedOptionModule` to add a deprecation warning.
  # `value` can be any attrset that can be passed to `mkOption`, or a string with the description of the option.
  mkDeprecatedOption =
    value:
    let
      attrs =
        if l.typeOf value == "string" then
          {
            description = value;
            example = true;
            type = l.types.bool;
          }
        else
          value;
    in
    l.mkOption (
      attrs
      // {
        description = ''
          ::: {.warning}
          THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
          FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
          NEXT RELEASE.
          :::

          ${if attrs ? description then attrs.description else ""}
        '';
        default = null;
        type = l.types.nullOr attrs.type;
      }
    );

  # returns a module that adds a deprecation warning if the specified option is set to a non-null value.
  # this is intended to be used the same way as `mkRemovedOptionModule` in nixpkgs,
  # but it does not create an option, it only adds a warning if the option is set to a non-null value.
  mkDeprecatedOptionModule =
    optionPath: message:
    { config, ... }:
    {
      config.warnings = l.optionals ((l.getAttrFromPath optionPath config) != null) [
        ''
          The option `${l.showOption optionPath}` is deprecated, and will be removed in a future release.
          Please remove this setting from your NixOS configuration.

          ${message}
        ''
      ];
    };

  # import wrapper to pass extra args to a module
  # used to pass the `l` variable to every module, and used in the importCategoryModule function to pass parentCfg and cfg.
  importModule =
    module: extraArgs: # `extraArgs` is a attrset that can contain any additional arguments to pass to the module
    (
      {
        lib,
        config,
        options,
        pkgs,
        ...
      }:
      ((if lib.typeOf module == "path" then import module else module) (
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
              mkDeprecatedOption
              mkDeprecatedOptionModule
              importModule
              importCategoryModule
              mkCategoryModules
              mkCategoryOptions
              mkCategoryConfig
              mkCategoryImports
              mkFilesystemOptions
              ;
          };
        }
        // extraArgs
      ))
    );

  # Converts a declarative attrset of filesystem options into a valid list.
  # It filters out options set to `false` and formats non-booleans
  # (e.g., `hidepid = 2` -> `"hidepid=2"`). If the resulting list is
  # empty, it avoids errors by defining no options at all.
  mkFilesystemOptions =
    optionAttrs:
    let
      finalOptions = l.attrNames (
        l.filterAttrs (_: bool: bool) (
          l.mapAttrs' (name: value: {
            name = if l.isBool value then name else "${name}=${toString value}";
            value = if l.isBool value then value else true;
          }) optionAttrs
        )
      );
    in
    l.mkIf (finalOptions != [ ]) finalOptions;

  # import a module using `importModule` and adds the args `parentCfg` and `cfg` to the module
  # `categoryConfig` is the config for the category the module belongs to, ex: config.nix-mineral.settings.kernel
  # `path` is the path to the module, ex: ./a-kernel-module.nix
  # `args` are the default arguments to pass to the module, needs to be: { inherit options config pkgs lib; }
  # ---
  # `parentCfg` is just the `categoryConfig` passed to the module
  # `cfg` is the child of parentCfg that has the base name of the path (without the .nix extension if any)
  importCategoryModule =
    categoryConfig: path: args:
    (importModule path {
      # pass the category config to the module
      parentCfg = categoryConfig;
      # pass the path base name as a config attribute
      # remove .nix extension if present
      cfg = categoryConfig.${l.removeSuffix ".nix" (l.baseNameOf path)};
    })
      args;

  # import many modules with `importCategoryModule` and creates a list with the results
  # `categoryConfig` is the config for the category the module belongs to, ex: config.nix-mineral.settings.kernel
  # `paths` is a list of paths to the modules, ex: [ ./a-kernel-module.nix ./another-kernel-module.nix ]
  # `args` are the default arguments to pass to the module, needs to be: { inherit options config pkgs lib; }
  mkCategoryModules =
    categoryConfig: paths: args:
    l.map (path: (importCategoryModule categoryConfig path args)) paths;

  # create an attrset with all options from a list of categoryModules created with `mkCategoryModules`
  mkCategoryOptions =
    modules:
    l.mergeAttrsList (l.map (module: if module ? options then module.options else { }) modules);

  # create a config for a list of categoryModules created with `mkCategoryModules`
  # use this to define a `config = ...` attrset
  mkCategoryConfig =
    modules: (l.mkMerge (l.map (module: if module ? config then module.config else { }) modules));

  # create a list of imports for a list of categoryModules created with `mkCategoryModules
  # this uses `importModule` to import the modules, so it will pass the `l` variable to every module
  # use this to define an `imports = ...` attrset
  mkCategoryImports =
    modules:
    l.concatMap (
      module:
      if module ? imports then
        (l.map (
          moduleImport:
          if l.typeOf moduleImport == "path" || l.typeOf moduleImport == "lambda" then
            importModule moduleImport { }
          else
            moduleImport
        ) module.imports)
      else
        [ ]
    ) modules;
in
{
  flake.lib = {
    inherit
      sources
      fetchGhFile
      mkBoolOption
      mkDeprecatedOption
      mkDeprecatedOptionModule
      importModule
      importCategoryModule
      mkCategoryModules
      mkCategoryOptions
      mkCategoryConfig
      mkCategoryImports
      ;
  };
}
