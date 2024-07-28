# nix-mineral
NixOS module for convenient system hardening.
Rather than be named after a mineral, it's named after the word "mineral."

## Scope
Reasonably harden NixOS in a way that can be quickly deployed by the end user. Threat model assumes non-governmental adversaries, and anonymity is not considered.

If you think the Feds are out to get you specifically, it's time to smash your hard drive and disappear.

## Usage
Extract the contents of the .zip provided in the releases to /etc/nixos, and import "nix-mineral.nix" into your configuration. Edit "nm-overrides.nix" to suit your use case or add the options to your configuration elsewhere, as the defaults are unlikely to be adequate.

In `configuration.nix`:

    imports = [ (./nix-mineral.nix) ... ];

### Example directory structure

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
