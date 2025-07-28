# nix-mineral
NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral".

## WARNING
`nix-mineral` is Alpha software! Loss of data or functionality may occur, especially on non-fixed releases, and user cooperation in debugging is expected!

## Scope
Reasonably harden NixOS in a way that can be quickly deployed by the end user.

`nix-mineral` primarily aims to configure, *not* install additional software unless the user explicitly does so (with the exception of AppArmor, since it's not known to cause any issues and has no functioning alternatives on NixOS). Although some alternate software could be considered more "secure" due to improved memory safety among other metrics, we avoid automatic replacements by default to help preserve user freedom.

Threat model assumes non-governmental adversaries, and anonymity is not considered.

If you think the Feds are out to get you specifically, it's time to smash your hard drive and disappear.

## Features
A non-comprehensive list of features in `nix-mineral`
### Defaults
  * Hardened sysctl
  * Hardened boot parameters
  * Disable editor in systemd-boot to prevent unauthorized modification of boot parameters
  * Empty securetty and enable pam_securetty.so to prevent root login on TTY
  * Use Whonix machine-id to reduce identifiers
  * Use Kicksecure Bluetooth configuration to automatically turn off bluetooth when unneeded
  * Comprehensive module blacklist to reduce attack surface, based on Kicksecure and secureblue
  * Mount option hardening on /home, /tmp, /var, /boot, and /dev/shm
  * hidepid on /proc to hide processes between users
  * Enable minimal firewall and block all incoming connections on all ports
  * Randomize MAC address in NetworkManager for increased privacy
  * Enable AppArmor and kill all processes that have an AppArmor profile but aren't confined
  * Disable core dumps
  * Increase hashing rounds in /etc/shadow (for new passwords only)
  * Require wheel to use su
  * Enforce 4 second delay on failed logins
  * Disallow root login in OpenSSH
  * Enable and require DNSSEC in systemd-resolved
  * Enable USBGuard to prevent BadUSB attacks
  * Enable jitterentropy-rngd and jitterentropy kernel module for additional entropy
  * Make all files in /home/$USER unreadable except by the owner
  * Make all files in /etc/nixos unreadable and uneditable except by root, since configuration files can sometimes end up owned by unprivileged users
  * Enable zram to reduce need to swap (potentially sensitive data) to disk
  * Require user to be in wheel to use nix
### Overrides
  Optional overrides are provided to quickly tweak `nix-mineral` to conform to different environments and workloads, such as by integrating USBGuard with GNOME, relaxing restrictions to allow Linux gaming, replacing systemd-timesyncd with a secure chrony configuration, and more.

  See [nm-overrides.nix](https://github.com/cynicsketch/nix-mineral/blob/main/nm-overrides.nix)

## Usage

### Automatic Installation (fetchgit)
(Can be used with flake and non-flake configurations, but if you are using flakes, the next flake specific method is objectively simpler and better for you in every way).

You can also use fetchFromGithub, fetchTarball or fetchUrl to your preference.

Example with fetchgit:
```nix
{ pkgs, ... }:
let
  nix-mineral = pkgs.fetchgit {
    url = "https://github.com/cynicsketch/nix-mineral.git";

    # now add one of the following:
    # a specific tag
    ref = "refs/tags/v0.1.6-alpha"; # Modify this tag as desired. Tags can be found here: https://github.com/cynicsketch/nix-mineral/tags. You will have to manually change this to the latest tagged release when/if you want to update.
    # or a specific commit hash
    rev = "cfaf4cf15c7e6dc7f882c471056b57ea9ea0ee61";
    # or the HEAD
    ref = "HEAD"; # This will always fetch from the head of main, however this does not guarantee successful configuration evaluation in future - if we change something and you rebuild purely, your evaluation will fail because the sha256 hash will have changed (so may require manually changing every time you evaluate, to get a successful evaluation).

    # After changing any of the above, you to update the hash.

    # Now the sha256 hash of the repository. This can be found with the nix-prefetch-url command, or (the simpler method) you can place an incorrect, but valid hash here, and nix will fail to evaluate and tell you the hash it expected (which you can then change this value to).
    # NOTE: this can be omitted if you are evaluating/building impurely.
    sha256 = "1mac9cnywpc4a0x1f5n45yn4yhady1affdmkimt2lg8rcw65ajh2";
  };
in
{
  imports = [
    "${nix-mineral}/nix-mineral.nix"
    # Other imports ...
  ];
  # The rest of your configuration ...
}
```
### Usage With Flakes

While you can use both of the other methods with flakes, it may be a little easier (and allow for easier updates and version pinning) by using this method.

Add nix-mineral as a non-flake input to your flake:

```nix
{
  inputs = {
    # ...
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral"; # Refers to the main branch and is updated to the latest commit when you use "nix flake update"
      # url = "github:cynicsketch/nix-mineral/v0.1.6-alpha" # Refers to a specific tag and follows that tag until you change it
      # url = "github:cynicsketch/nix-mineral/cfaf4cf15c7e6dc7f882c471056b57ea9ea0ee61" # Refers to a specific commit and follows that until you change it
      flake = false;
    };
    # ...
  };
}
```

Import nix-mineral.nix from the repository path:

```nix
{
  imports = [
    "${inputs.nix-mineral}/nix-mineral.nix"
    # Other imports ...
  ];
  # The rest of your configuration ...
}
```

You can then use the `nm-overrides` config option to tweak the overrides to your liking.

### Manual Installation
(Can be used with flake and non-flake configurations)

You may want to use this method if you prefer to be in control of your own configuration, or if you need to directly edit `nix-mineral.nix` to remove/add your own options, however, this method requires manual updates if anything is changed in this repository. You could also fork this repository and use your fork with the automatic options to achieve the same effect.

Extract the contents of the .zip provided in the releases to `/etc/nixos` (or download from main using the  `<> Code` -> `Download Zip` dropdown), and import `nix-mineral.nix` into your configuration. Edit `nm-overrides.nix` to suit your use case or add the options to your configuration elsewhere, as the defaults are unlikely to be adequate.

In `configuration.nix`:

```nix
{
  imports = [
    ./nix-mineral.nix
    # Other imports ...
  ];
  # The rest of your configuration ...
}
```

#### Example directory structure
Some individual modules may be missing in this example, but should show roughly what `/etc/nixos/` would look like.

    $ tree /etc/nixos

    /etc/nixos
    ├── configuration.nix
    ├── hardware-configuration.nix
    ├── nix-mineral.nix
    ├── nm-overrides
    │   ├── compatibility
    │   │   ├── allow-unsigned-modules.nix
    │   │   ├── binfmt-misc.nix
    │   │   ├── busmaster-bit.nix
    │   │   ├── io-uring.nix
    │   │   ├── ip-forward.nix
    │   │   └── no-lockdown.nix
    │   ├── desktop
    │   │   ├── allow-multilib.nix
    │   │   ├── allow-unprivileged-userns.nix
    │   │   ├── doas-sudo-wrapper.nix
    │   │   ├── hideproc-relaxed.nix
    │   │   ├── home-exec.nix
    │   │   ├── nix-allow-all-users.nix
    │   │   ├── tmp-exec.nix
    │   │   ├── usbguard-allow-at-boot.nix
    │   │   ├── usbguard-disable.nix
    │   │   ├── usbguard-gnome-integration.nix
    │   │   ├── var-lib-exec.nix
    │   │   └── yama-relaxed.nix
    │   ├── performance
    │   │   ├── allow-smt.nix
    │   │   ├── iommu-passthrough.nix
    │   │   ├── no-mitigations.nix
    │   │   └── no-pti.nix
    │   ├── security
    │   │   ├── hardened-malloc.nix
    │   │   ├── lock-root.nix
    │   │   ├── minimum-swappiness.nix
    │   │   ├── sysrq-sak.nix
    │   │   └── tcp-timestamp-disable.nix
    │   └── software-choice
    │       ├── doas-no-sudo.nix
    │       ├── hardened-kernel.nix
    │       ├── no-firewall.nix
    │       └── secure-chrony.nix
    └── nm-overrides.nix

#### Contributing
Have any ideas for the project? Want to help improve it by writing code or documentation? Head to the [issues tracker](https://github.com/cynicsketch/nix-mineral/issues) and we can talk a solution!

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
