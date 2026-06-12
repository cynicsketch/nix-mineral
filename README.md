# nix-mineral
`nix-mineral` is a NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral".

## WARNING
`nix-mineral` is Alpha software! Loss of data or functionality may occur, especially on non-fixed releases, and user cooperation in debugging is expected!

## Documentation
- **[cynicsketch.github.io/nix-mineral](https://cynicsketch.github.io/nix-mineral/)** - All documentation as well as option information/search is available on the website
- **[Contributing Guidelines](docs/CONTRIBUTING.md)** - Information for contributors
- **[Scope](docs/SCOPE.md)** - Details what this project is for
- **[Additional Resources](docs/ADDITIONAL-RESOURCES.md)** - Other projects and information that may useful but didn't fit elsewhere
- **[Omitted Features](docs/OMITTED.md)** - Things that have been intentionally omitted

## Features
A full rundown of features is best obtained by reading the individual submodules
for every option `nix-mineral` offers.

Some notable features include:
- Filesystem hardening with both systemd-tmpfiles and mount options
- Extensive kernel hardening using sysctl and boot parameters
- Network hardening through sysctl and configuration of relevant services
- Attack surface reduction by an extensive kernel module blacklist
- System entropy hardening

## Usage

### Automatic Installation (fetchgit)
May be used with or without flakes. However, the flake specific method in the next section is preferred because it allows version pinning.

Since we are using flake-compat inside the project, you can use the `nix-mineral` without needing to have flakes enabled, using `fetchGit`

Example with fetchgit:
```nix
let
    nix-mineral = builtins.fetchGit {
      url = "https://github.com/cynicsketch/nix-mineral.git";
    };
in
{
  imports = [
    nix-mineral.nixosModules.nix-mineral
  ];

  nix-mineral = {
    enable = true;
  };
}
```
### Usage With Flakes

For use in flake enabled systems, and to enable automatic updates and version pinning, use this method.

Add nix-mineral as an input to your flake:

```nix
{
  description = "Example flake for using nix-mineral";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-mineral.url = "github:cynicsketch/nix-mineral/"; # Refers to the main branch and is updated to the latest commit when you use "nix flake update"

    # Note that due to major breaking changes, the below examples are not compatible with commits or releases prior to 0.2.0a!

    # nix-mineral.url = "github:cynicsketch/nix-mineral/v0.2.0-alpha" # Refers to a specific tag and follows that tag until you change it
    # nix-mineral.url = "github:cynicsketch/nix-mineral/reallylongexamplehashforthecommitandall9" # Refers to a specific commit and follows that until you change it
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations.ExampleSystem = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./configuration.nix
        ];
      };
    };
}
```

Import nix-mineral.nix from the input and enable the module:

```nix
{ inputs, ... }:

{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  nix-mineral = {
    enable = true;
  };
}
```

### Configuring options
It is likely you will need to change some options in order to make your
individual hardware and software configuration function as intended.

Presets for doing so are available in the [presets directory](https://github.com/cynicsketch/nix-mineral/tree/main/presets)
of this repository.

Refer to the individual submodules for more information on what each option does.

An example configuration to enable all defaults, use the "compatibility" preset, and then disable TCP window
scaling while enabling multilib support and IP forwarding functionality is
shown below.
```nix
{
    nix-mineral = {
        enable = true;
        
        # Multiple presets can be used.
        # The order of presets matters, the top ones will receive higher
        # priority values, meaning that presets LOWER in the list are prioritized.

        # In this example, all settings from the "compatibility" preset have
        # an override priority of 800, while settings from the "performance"
        # preset will have an override priority of 799.

        # See: https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities
        preset = [
          "compatibility"
          "performance"
        ];

        settings = {
            # kernel = {
            #     only-signed-modules = true;
            #     lockdown = true;
            #     ...
            # };
            system.multilib = true;
            network = {
                ip-forwarding = true;
            };
        };
    };

    nix-mineral.settings.network.tcp-window-scaling = false;
}
```

### Credits
Special thanks to all our [wonderful contributors](https://github.com/cynicsketch/nix-mineral/graphs/contributors) who have helped make this project possible, as well many other projects, named and unnamed, which `nix-mineral` has borrowed insight and configuration from:

Project: *Madaidan's Insecurities* \
Influence: Provided the original basis for hardening, which many of the below projects have themselves derived from \
URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html \
Archive: https://web.archive.org/web/20220320000126/https://madaidans-insecurities.github.io/guides/linux-hardening.html

Project: *privsec's Desktop Linux Hardening* \
Influence: Additional information and guidance in hardening \
URL: https://privsec.dev/posts/linux/desktop-linux-hardening/ \
Archive: https://web.archive.org/web/20240629135847/https://privsec.dev/posts/linux/desktop-linux-hardening/#kernel

Project: *Kicksecure's security-misc* \
Influence: Borrowed Bluetooth configuration and module blacklist, with additional settings inspiration  \
URL: https://github.com/Kicksecure/security-misc

Project: *Tommy's Linux-Setup-Scripts* \
Influence: Provided supplement to sysctl hardening \
URL: https://github.com/Metropolis-nexus/Common-Files/blob/main/etc/sysctl.d/99-workstation.conf

Project: *GrapheneOS server infrastructure*  \
Influence: Providing optional borrowed chrony configuration \
URL: https://github.com/GrapheneOS/infrastructure

Blog: *Xe Iaso* \
Influence: Providing the original idea to restrict nix to the wheel user \
URL: https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

Project: *K4YT3X's sysctl*
Influence: Providing supplement for various security-relevant sysctl configuration \
URL: https://github.com/k4yt3x/sysctl/blob/master/sysctl.conf

NixOS Module: `hardened.nix` profile upstream \
Influence: Inspiration for the creation of `nix-mineral` \
URL: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix

Project: *nix-bitcoin's hardening* \
Influence: Inspiration for the creation of `nix-mineral` \
URL: https://github.com/fort-nix/nix-bitcoin

Project: *hjem* \
Influence: Snippets used licensed under the MPL-2.0, used to generate `nix-mineral`'s website \
URL: https://github.com/feel-co/hjem

Project: *hjem-rum* \
Influence: Snippets used licensed under the GPL-3.0, used to generate `nix-mineral`'s website \
URL: https://github.com/snugnug/hjem-rum

