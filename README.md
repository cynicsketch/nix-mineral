# nix-mineral
NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral".

## WARNING
`nix-mineral` is Alpha software! Loss of data or functionality may occur, especially on non-fixed releases, and user cooperation in debugging is expected!

## Scope
Reasonably harden NixOS in a way that can be quickly deployed by the end user.

`nix-mineral` primarily aims to configure, *not* install additional software unless the user explicitly does so. There are specific exceptions for software which is not known to cause any problems to any workflow.

Refer to [our contribution guidelines](docs/CONTRIBUTING.md) for more information on what we choose to exclude.

Threat model assumes non-governmental adversaries, and anonymity is not considered.

If you think the Feds are out to get you specifically, it's time to smash your hard drive and disappear.

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
(Can be used with flake and non-flake configurations, but if you are using flakes, the next flake specific method is objectively simpler and better for you in every way).

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

While you can use both of the other methods with flakes, it may be a little easier (and allow for easier updates and version pinning) by using this method.

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
It is very likely you will need to change some options in order to make your
individual hardware and software function as intended.

Some presets for doing so are available below:
[](https://github.com/cynicsketch/nix-mineral/tree/main/presets)

Refer to the individual submodules for more information on what each option does.

An example configuration to enable all defaults, and then disable TCP window
scaling while enabling multilib support and IP forwarding functionality is
shown below.
```nix
{
    nix-mineral = {
        enable = true;

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

#### Contributing
Have any ideas for the project? Want to help improve it by writing code or documentation? Head to the [issues tracker](https://github.com/cynicsketch/nix-mineral/issues) and we can talk a solution!
Also see [our contribution guidelines](docs/CONTRIBUTING.md) for more information.

### Credits
Special thanks to all our [wonderful contributors](https://github.com/cynicsketch/nix-mineral/graphs/contributors) who have helped make this project possible, as well many other projects, named and unnamed, which `nix-mineral` has borrowed insight and configuration from:

Original basis for hardening, of which many of the below have themselves derived from:
URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html
Archive: https://web.archive.org/web/20220320000126/https://madaidans-insecurities.github.io/guides/linux-hardening.html

Additionally used is privsec's Desktop Linux Hardening:
URL: https://privsec.dev/posts/linux/desktop-linux-hardening/
Archive: https://web.archive.org/web/20240629135847/https://privsec.dev/posts/linux/desktop-linux-hardening/#kernel

Bluetooth configuration and module blacklist, with various additional settings inspiration from Kicksecure's security-misc:
URL: https://github.com/Kicksecure/security-misc

Supplement to sysctl configuration borrowed from Tommy's Linux-Setup-Scripts:
URL: https://github.com/TommyTran732/Linux-Setup-Scripts/blob/main/etc/sysctl.d/99-workstation.conf

Optional chrony configuration was borrowed from GrapheneOS server infrastructure:
URL: https://github.com/GrapheneOS/infrastructure

Original idea to restrict nix to wheel user from Xe Iaso:
URL: https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

Various security-relevant sysctl configuration from K4YT3X's sysctl:
URL: https://github.com/k4yt3x/sysctl/blob/master/sysctl.conf

The `hardened.nix` profile upstream, which inspired this project:
URL: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix

nix-bitcoin's hardening, which have also inspired this project:
URL: https://github.com/fort-nix/nix-bitcoin
