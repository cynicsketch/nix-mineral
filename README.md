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
Extract the contents of the .zip provided in the releases to `/etc/nixos`, and import `nix-mineral.nix` into your configuration. Edit `nm-overrides.nix` to suit your use case or add the options to your configuration elsewhere, as the defaults are unlikely to be adequate.

In `configuration.nix`:

    imports = [ (./nix-mineral.nix) ... ];

### Example directory structure
Some individual modules may be missing in this example, but should show roughly what `/etc/nixos/` would look like.

    [nix-shell:~]$ tree /etc/nixos
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
    
    7 directories, 36 files
    
    [nix-shell:~]$ 

## Usage with flakes

While you can use the above method with flakes, it may be a little easier (and allow for easier updates and version pinning) by using this method.

Add nix-mineral as a non-flake input to your flake:

```nix
{
  inputs = {
    # ...
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };
    # ...
  };
}
```

Import nix-mineral.nix from the repository:

```nix
{
  imports = [
    "${inputs.nix-mineral}/nix-mineral.nix"
  ];
  # ...
}
```

With this method, you can use the `nm-overrides` config option.
