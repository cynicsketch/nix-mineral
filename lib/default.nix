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

  mkBoolOption =
    desc: bool:
    l.mkOption {
      default = bool;
      example = !bool;
      description = desc;
      type = l.types.bool;
    };

  # just a import wrapper to pass the l variable
  importModule =
    path: extraArgs: # pass extra attributes to the module, used in the categorySubmodule function
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

  mkCategoryModules =
    categoryConfig: paths: args:
    l.map (path: (importCategoryModule categoryConfig path args)) paths;

  mkCategorySubmodule =
    modules:
    (l.types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = l.map (module: {
        inherit (module) options;
      }) modules;
    });

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
