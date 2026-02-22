# Contributing

One of the main ideas is to be as modular as possible, so don't create modules that do too many things at the same time, always try to separate them into smaller modules, with unique responsibilities.

# Table of Contents

- [Rules](#rules)
- [Libs](#libs)
- [Creating a module](#creating-a-module)
- [Creating a category](#creating-a-category)
- [Hardening a filesystem](#hardening-a-filesystem)
- [Creating a preset](#creating-a-preset)
- [Adding functions to the lib](#adding-functions-to-the-lib)
- [Licensing and copyright](#licensing-and-copyright)

# Rules

- Whenever you need to use lib/builtins functions, use the `l` attribute, which is available in all modules. It contains all lib functions, builtins, and additional nix-mineral functions.
- Format the code with the formatter in `flake.nix`. If using NixOS, use the `nix fmt` command within the repository, which will format all files with the correct formatter.
- Explain the options in their descriptions (or in comments). The reason for each setting, and WHY this setting makes the system more secure for the user.
- When creating new settings, use names in lowercase and hyphens to separate words, for example: `example-feature-x`.
- Invert options that are intended to disable something, for example: don't use `disable-example-feature-y`, use `example-feature-y` and set the default to `false`.
- Use the `l.mkBoolOption` function to create boolean options.
- Do not attempt to add any feature which has been intentionally excluded under [OMITTED.md](OMITTED.md) or [ADDITIONAL-RESOURCES.md](ADDITIONAL-RESOURCES.md) without first creating an issue.
- Issues should be created for most feature changes before attempting a PR. Bug fixes, and minor documentation changes do not require issues, but it is still heavily encouraged.
- Where applicable, update both [presets](https://github.com/cynicsketch/nix-mineral/tree/main/presets) and the [README](https://github.com/cynicsketch/nix-mineral/tree/main/README.md) to reflect any new options.
- Use `l.mkOverride 900` over `l.mkForce` when forcefully overriding NixOS defaults is necessary, to make sure it actually applies.
- Where applicable, add [GPL license headers](https://www.gnu.org/licenses/gpl-3.0.html#howto) to new source code files:

```
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
```

# Libs

nix-mineral has a library with things used in several files in the project, to avoid code repetition. Common things you'll likely use are explained here. Each function declaration and detailed explanations are located in the `lib/default.nix` file.
`l` is an attrset with all the lib functions, builtins functions, and nix-mineral functions. So use `l` to access any function below.

---

`l.mkBoolOption`: Creates a boolean option with description and default value.

Takes 2 arguments:
desc, bool

Example:

```nix
# Creates an option with mkOption which is a boolean, with the description "Enable example feature X" and default value `true`
l.mkBoolOption "Enable example feature X" true
```

---

`l.sources`: Attrset with all sources inside the `lib/sources.toml` file (Used with fetchGhFile, fetchGit, fetchTarball, etc).

---

`l.fetchGhFile`: Fetches a file directly from a GitHub repository.

Args:

- `user`: GitHub username or organization name.
- `repo`: Repository name.
- `rev`: Branch, tag or commit.
- `file`: Path to the file within the repository.
- `sha256`: Hash sha256 of the file.

Examples:

```nix
l.fetchGhFile {
  user = "cynicsketch";
  repo = "nix-mineral";
  rev = "b76cc19351f159cd360d8ceea3ba9aff8fce6c6e";
  file = "README.md";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
}
```

Using with `l.sources`:

```nix
# Fetches the example-file from the repository defined in l.sources.example-file
l.fetchGhFile l.sources.example-file
```

---

`l.importModule`: import wrapper to pass extra args to a module, and also pass the lib `l`.

Takes 2 arguments:
path, extraArgs

Example:

```nix
# Imports the module at ./example-module.nix, passing the lib `l` and an extra argument `customArg` with value "value"
# The imported module is the same as using the nix import function.
l.importModule ./example-module.nix { customArg = "value"; }
```

# Creating a module

1. Choose a module type:
   `settings`: Main settings, which modify things in the `default` preset.
   `extras`: Extra settings, which modify things only if specified by the user, and may contain opinionated additional software.

2. Choose a category:
   Enter the folder for your chosen module type, and choose a category to place your module in (or [create a new one](#creating-a-category) if needed).

3. Create the module file:
   Let's say I want to create a `settings` module in the `system` category. Here's what the process would look like:

First, I create a file `example-module.nix` inside the `system` folder with this:

```nix
{
  pkgs,

  # The "l" variable includes all the functions from nixpkgs.lib, builtins, and nix-mineral libs.
  # This is to avoid having to declare something like `l = lib // builtins // ...` in every module, as was the case before.
  l,

  # The "cfg" variable contains the option within the category that has the same name as the file.
  # In this case, it's the same as setting `cfg = config.nix-mineral.system.example-module`
  cfg,

  # The parentCfg variable contains the category configuration if needed.
  # In this case, it is the same as setting `parentCfg = config.nix-mineral.system`
  parentCfg,
  ...
}:

{
  options = {
    # I use the mkBoolOption constructor to create a boolean option,
    # with a default description and value.
    example-module = l.mkBoolOption ''
      This is just a example module, enabled by default.
    '' true;
  };

  # `cfg` is equivalent to the value defined in `example-module` within the `options` attribute above,
  # so using `mkIf`, all the config below will only be enabled if the module itself is enabled.
  config = l.mkIf cfg {
    environment.systemPackages = with pkgs; [ firefox ];
  };
}
```

4. Import the module:
   Inside the `system` folder, there is a file with the name `default.nix`, which imports all modules within that category.
   You just need to add the relative file path to the `categoryModules` list inside the `settings/system/default.nix` file.

5. Examples of different modules:
   `settings/system/multilib.nix`: A simple module.
   `settings/kernel/cpu-mitigations.nix`: A module that uses an enum instead of a bool.
   `extras/misc/usbguard.nix`: A module with several options.

# Creating a category

1. Choose a module type:
   `settings`: Main settings, which modify things in the `default` preset.
   `extras`: Extra settings, which modify things only if specified by the user, and may contain opinionated additional software.

2. Create a folder with the category name within the chosen module type:
   Example: `settings/new-category`

3. Create a `default.nix` file inside the category folder:
   Example: `settings/new-category/default.nix`
   Place the following code inside the file, adapting the name, description, and the modules you want to add:

```nix
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
        # Add here the relative paths to the modules within this category
        ./example-module.nix
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
    new-category = l.mkOption {
      description = ''
        This is a new category example.
      '';
      default = { };
      type = l.mkCategorySubmodule categoryModules;
    };
  };

  config = l.mkCategoryConfig categoryModules;
}
```

4. Import the category:
   Within the `nix-mineral.nix` file, import the category by adding the relative path of the category folder to the `settingsModules` or `extrasModules` list, depending on the type of category you created.
   Example: `settings/new-category` would be imported within the `settingsModules` list in the `nix-mineral.nix` file.

# Hardening a filesystem

To harden a filesystem, you follow the same options a normal user would use, but simply place these options inside the `filesystems/normal.nix` or `filesystems/special.nix` modules, depending on the type of filesystem you want to harden.
Examples are within the files.

# Creating a preset

1. Create a file with the preset name inside the `presets` folder:
   Example: `presets/example-preset.nix`
   The code inside the file is the same as what a normal user would use to configure nix-mineral,
   but each option must be set using `mkPreset` or `mkPresets` functions.
   `mkPreset` is used to set a single option, while `mkPresets` is used to set multiple options within an attrset.
   An example of a preset below:

```nix
{
  mkPresets,
  ...
}:

{
  nix-mineral = mkPresets {
    settings = {
      kernel = {
        lockdown = false;
        only-signed-modules = false;
      };
    };
    extras = {
      system = {
        lock-root = true;
      };
    };
  };
}
```

2. Add your preset to the `presets/default.nix` file:
   In the `presets` attrset at the top of the file, add your preset with the name as the key and the description as the value.
   Your preset name must match the filename you created in step 1. This will automatically import the preset file when the user includes the preset name in their configuration.

# Adding functions to the lib

Create your function within the `let in` in the `lib/default.nix` file, following the pattern of the other functions.
Then place your function within the `flake.lib` list at the end of the file, and within the list inside the `importModule` function as well.

# Licensing and copyright

Because it is pragmatic to take from existing research, consideration to licensing applies.

This is not legal advice. The information provided is for general informational
purposes only and may not reflect the most current legal developments. The
author is not an attorney and makes no guarantees regarding the accuracy or
completeness of this information. The author disclaims any liability for
actions taken or not taken based on the content provided.

- Invidividual, purely functional configuration decisions and purely factual statements are usually not copyrightable due to merger doctrine.
- Informal crediting exists as a courtesy, not as a way to fulfill proper license attribution requirements.
- If in doubt, do not blindly copy. Use proper license attribution where permitted and required.
