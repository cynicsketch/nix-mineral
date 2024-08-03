# nix-mineral
NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral."

## Scope
Reasonably harden NixOS in a way that can be quickly deployed by the end user. Threat model assumes non-governmental adversaries, and anonymity is not considered.

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

### Manual Installation
(Can be used with flake and non-flake configurations)

You may want to use this method if you prefer to be in control of your own configuration, or if you need to direcly edit `nix-mineral.nix` to remove/add your own options, however, this method requires manual updates if anything is changed in this repository. You could also fork this repository and use your fork with the automatic options to acheive the same effect.

Extract the contents of the .zip provided in the releases to `/etc/nixos` (or download from master using the  `<> Code` -> `Download Zip` dropdown), and import `nix-mineral.nix` into your configuration. Edit `nm-overrides.nix` to suit your use case or add the options to your configuration elsewhere, as the defaults are unlikely to be adequate.

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
    

## Usage with flakes

### Usage With Flakes

While you can use both of the above methods with flakes, it may be a little easier (and allow for easier updates and version pinning) by using this method.

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
