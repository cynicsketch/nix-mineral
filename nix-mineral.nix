# This is the main module for nix-mineral, containing the default configuration.

# Primarily sourced was madaidan's Linux Hardening Guide. See for details: 
# URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html
# Archive: https://web.archive.org/web/20220320000126/https://madaidans-insecurities.github.io/guides/linux-hardening.html 

# Additionally sourced is privsec's Desktop Linux Hardening:
# URL: https://privsec.dev/posts/linux/desktop-linux-hardening/
# Archive: https://web.archive.org/web/20240629135847/https://privsec.dev/posts/linux/desktop-linux-hardening/#kernel

# Bluetooth configuration and module blacklist, and many more config files were
# borrowed from Kicksecure's security-misc:
# URL: https://github.com/Kicksecure/security-misc

# Supplement to module blacklisting borrowed from secureblue config:
# URL: https://github.com/secureblue/secureblue/blob/live/config/files/usr/etc/modprobe.d/blacklist.conf

# Supplement to sysctl configuration borrowed from Tommy's Linux-Setup-Scripts:
# URL: https://github.com/TommyTran732/Linux-Setup-Scripts/blob/main/etc/sysctl.d/99-workstation.conf

# Chrony configuration was borrowed from GrapheneOS server infrastructure:
# URL: https://github.com/GrapheneOS/infrastructure

# Original idea to restrict nix to wheel user from Xe Iaso:
# URL: https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

# NixOS snippet for hiding process information from anon* (obviously throwaway
# Reddit account)
# URL: https://www.reddit.com/r/NixOS/comments/1aqfuxq/bootloaderkernel_hardening_for_nixos/

# More relevant sysctl configuration from K4YT3X's sysctl:
# URL: https://github.com/k4yt3x/sysctl/blob/master/sysctl.conf

# sysctl omitted from K4YT3X config that are out of scope of nix-mineral and
# hardening  but may be useful anyways to some, see their repo for details:
# kernel.core_uses_pid = 1
# kernel.pid_max = 4194304
# kernel.panic = 10
# fs.file-max = 9223372036854775807
# fs.inotify.max_user_watches = 524288
# net.core.netdev_max_backlog = 250000
# net.core.rmem_default = 8388608
# net.core.wmem_default = 8388608
# net.core.rmem_max = 536870912
# net.core.wmem_max = 536870912
# net.core.optmem_max = 40960
# net.ipv4.tcp_congestion_control = bbr
# net.ipv4.tcp_synack_retries = 5
# net.ipv4.ip_local_port_range = 1024 65535
# net.ipv4.tcp_slow_start_after_idle = 0
# net.ipv4.tcp_mtu_probing = 1
# net.ipv4.tcp_base_mss = 1024
# net.ipv4.tcp_rmem = 8192 262144 536870912
# net.ipv4.tcp_wmem = 4096 16384 536870912
# net.ipv4.tcp_adv_win_scale = -2
# net.ipv4.tcp_notsent_lowat = 131072

# Sections from madaidan's guide that are IRRELEVANT/NON-APPLICABLE:
# 1. (Advice)
# 2.1 (Advice)
# 2.3.3 (Advice)
# 2.5.1 (Advice)
# 2.5.3 (Advice)
# 2.6 (Advice)
# 2.10 (Package is broken)
# 7 (Advice)
# 10.5.4 (The problem of NTP being unencrypted is fixed by using NTS instead.
# Note that this means using chrony, as in "Software Choice" in the overrides,
# which is not default behavior!)
# 11 (Partially, there seems to be no way to edit the permissions of /boot
# whether with mount options or through tmpfiles)
# 15 (Implemented by default)
# 19 (Advice)
# 20 (Not relevant)
# 21.7 (Advice, not in threat model)
# 22 (Advice)

# Sections from madaidan's guide requiring manual user intervention:
# 2.7 (systemd service hardening must be done manually)
# 2.9 (Paid software)
# 2.11 (Unique for all hardware, inconvenient)
# 4 (Sandboxing must be done manually)
# 6 (Compiling everything is inconvenient)
# 8.6 (No option, not for all systems)
# 8.7 (Inconvenient, depends on specific user behavior)
# 10.1 (Up to user to determine hostname and username)
# 10.2 (Up to user to determine timezone, locale, and keymap)
# 10.5.3 (Not packaged)
# 10.6 (Not packaged, inconvenient and not within threat model)
# 11.1 (Manual removal is SUID/SGID is manual)
# 11.2 (No known way to set umask declaratively systemwide, use your shellrc
# or home manager to do so)
# 14 (Rather than enforce password quality with PAM, expect user
# to enforce their own password quality; faildelay is, however,
# implemented here)
# 21.1 (Out of scope)
# 21.2 (See above)
# 21.3 (User's job to set passwords)
# 21.3.1 (See above)
# 21.3.2 (See above)
# 21.3.3 (See above)
# 21.4 (Non-declarative setup, experimental)

# ABOUT THE DEFAULTS:
# The default config harms performance and usability in many ways, focusing
# almost entirely on hardening alone.
#
# There are also some optional software substitutions and additions in the
# overrides that are recommended but *not enabled* by default:
#
# sudo ---> doas (For reduced attack surface; although less audited)
# systemd-timesyncd ---> chrony (For NTS support)
# linux_hardened kernel*
#
# (No longer recommended as of July 25, 2024. The patchset being behind by
# about a week or so is one thing, but the package as included in nixpkgs is
# way too infrequently updated, being several weeks or even months behind.
# Therefore, it is recommended to choose an LTS kernel like 5.15, 6.1, or 6.6
# in your own system configuration.*)
#
# USBGuard is also *enabled* by default, which may inconvenience some users.
# 
# All of this can, and should be addressed using the overrides file.
# "nm-overrides.nix"

{
  config,
  lib,
  pkgs,
  ...
}:
let
  l = lib // builtins;
  sources = l.fromTOML (l.readFile ./sources.toml);
  /*
    helper function to fetch a file from a github repository

    example usage to fetch https://raw.githubusercontent.com/Kicksecure/security-misc/de6f3ea74a5a1408e4351c955ecb7010825364c5/usr/lib/issue.d/20_security-misc.issue

    fetchGhFile {
      user = "Kicksecure";
      repo = "security-misc";
      rev = "de6f3ea74a5a1408e4351c955ecb7010825364c5";
      file = "usr/lib/issue.d/20_security-misc.issue";
      sha256 = "00ilswn1661h8rwfrq4w3j945nr7dqd1g519d3ckfkm0dr49f26b";
    }
  */
  fetchGhFile =
    {
      user,
      repo,
      rev,
      file,
      sha256,
      ...
    }:
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/${user}/${repo}/${rev}/${file}";
      inherit sha256;
    };
in
{

options.nix-mineral = { 
  enable = l.mkOption {
    type = types.bool;
    default = false;
    description = ''
    Enable all nix-mineral defaults.
    '';
  };
  overrides = {
    compatibility = {
      allow-unsigned-modules = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Allow loading unsigned kernel modules.
        '';
      };
      allow-binfmt-misc = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable binfmt_misc.
        '';
      };
      allow-busmaster-bit = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable the busmaster bit at boot.
        '';
      };
      allow-io-uring = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable io_uring.
        '';
      };
      allow-ip-forward = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable ip forwarding.
        '';
      };
      no-lockdown = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Disable Linux Kernel Lockdown.
        '';
      };  
    };
    desktop = { 
      allow-multilib = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable support for 32 bit applications.
        '';
      };
      allow-unprivileged-userns = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Allow unprivileged userns.
        '';
      };
      doas-sudo-wrapper = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Enable doas-sudo wrapper, with nano to utilize rnano as a "safe"
        editor for editing as root.
        '';
      };
    };
    performance = {
      allow-smt = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Reenable symmetric multithreading.
        '';
      };
      iommu-passthrough = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Enable bypassing the IOMMU for direct memory access.
        '';
      };
      no-mitigations = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Disable all CPU vulnerability mitigations.
        '';
      };
      no-pti = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Disable page table isolation.
        '';
      };
    };
    security = {

    };
    software-choice = {
      doas-no-sudo = l.mkOption {
        type = types.bool;
        default = false;
        description = ''
        Replace sudo with doas.
        '';
      };
    };
    use-hardened-kernel = l.mkOption {
      type = types.bool;
      default = false;
      description = ''
      Use Linux kernel with hardened patchset.
      '';
    };
    no-firewall = l.mkOption {
      type = types.bool;
      default = false;
      description = ''
      Disable default firewall as chosen by nix-mineral.
      '';
    };
  };
};

config = l.mkMerge [
  
  # Compatibility

  (mkIf config.nix-mineral.overrides.compatibility.allow-unsigned-modules {
    boot.kernelParams = l.mkOverride 100 [ ("module.sig_enforce=0") ];
  })

  (mkIf config.nix-mineral.overrides.compatibility.allow-binfmt-misc {
    boot.kernel.sysctl."fs.binfmt_misc.status" = l.mkForce "1";
  })

  (mkIf config.nix-mineral.overrides.compatibility.allow-busmaster-bit {
    boot.kernelParams = l.mkOverride 100 [ ("efi=no_disable_early_pci_dma") ];
  })

  (mkIf config.nix-mineral.overrides.compatibility.allow-io-uring {
    boot.kernel.sysctl."kernel.io_uring_disabled" = l.mkForce "0";
  })

  (mkIf config.nix-mineral.overrides.compatibility.allow-ip-forward {
    boot.kernel.sysctl."net.ipv4.ip_forward" = l.mkForce "1";
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = l.mkForce "1";
    boot.kernel.sysctl."net.ipv4.conf.default.forwarding" = l.mkForce "1";
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = l.mkForce "1";
    boot.kernel.sysctl."net.ipv6.conf.default.forwarding" = l.mkForce "1";
  })

  (mkIf config.nix-mineral.overrides.compatibility.no-lockdown {
    boot.kernelParams = l.mkOverride 100 [ ("lockdown=") ];
  })

  # Desktop

  (mkIf config.nix-mineral.overrides.desktop.allow-multilib {
    boot.kernelParams = l.mkOverride 100 [ ("ia32_emulation=1") ];
  })

  (mkIf config.nix-mineral.overrides.desktop.allow-unprivileged-userns.enable {
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = l.
    l.mkForce "1";
  })
  
  (mkIf config.nix-mineral.overrides.desktop.doas-sudo-wrapper {
    environment.systemPackages = (with pkgs; [ 
      ((pkgs.writeScriptBin "sudo" ''exec doas "$@"''))
      ((pkgs.writeScriptBin "sudoedit" ''exec doas rnano "$@"''))
      ((pkgs.writeScriptBin "doasedit" ''exec doas rnano "$@"''))
      nano
    ]);
  })

  ()

  ()

  ()

  ()

  ()

  ()

  ()

  ()

  ()

  # Performance

  (mkIf config.nix-mineral.overrides.performance.allow-smt {
    boot.kernelParams = l.mkOverride 100 [ ("mitigations=auto") ];
  })

  (mkIf config.nix-mineral.overrides.performance.iommu-passthrough {
    boot.kernelParams = l.mkOverride 100 [ ("iommu.passthrough=1")  ];
  })

  (mkIf config.nix-mineral.overrides.performance.no-mitigations {
    boot.kernelParams = l.mkOverride 100 [ ("mitigations=off") ];
  })

  (mkIf config.nix-mineral.overrides.performance.no-pti {
    boot.kernelParams = l.mkOverride 100 [ ("pti=off") ];
  })

  # Security

  # Software Choice

  (mkIf config.nix-mineral.overrides.software-choice.doas-no-sudo {
    security.sudo = { enable = false; }; 
    security.doas = { 
      enable = true;
      extraRules = [
        ({
          keepEnv = true;
          persist = true;
          users = [ ("user") ];
        })
      ];
    };
  })

  (mkIf config.nix-mineral.overrides.software-choice.use-hardened-kernel {
    boot.kernelPackages = l.mkForce (pkgs).linuxPackages_hardened;
  })

  (mkIf config.nix-mineral.overrides.software-choice.no-firewall {
    networking.firewall.enable = l.mkForce false;
  })

  ()

  # Main module

  (mkIf config.nix-mineral.enable {
    boot = {
      kernel = {
        sysctl = {
          # Unprivileged userns has a large attack surface and has been the cause
          # of many privilege escalation vulnerabilities, but can cause breakage.
          # See overrides.
          "kernel.unprivileged_userns_clone" = "0";

          # Yama restricts ptrace, which allows processes to read and modify the
          # memory of other processes. This has obvious security implications.
          # See overrides.
          "kernel.yama.ptrace_scope" = "3";

          # Disables magic sysrq key. See overrides file regarding SAK (Secure
          # attention key).
          "kernel.sysrq" = "0";

          # Disable binfmt. Breaks Roseta, see overrides file.
          "fs.binfmt_misc.status" = "0";

          # Disable io_uring. May be desired for Proxmox, but is responsible
          # for many vulnerabilities and is disabled on Android + ChromeOS.
          # See overrides file.
          "kernel.io_uring_disabled" = "2";

          # Disable ip forwarding to reduce attack surface. May be needed for
          # VM networking. See overrides file.
          "net.ipv4.ip_forward" = "0";
          "net.ipv4.conf.all.forwarding" = "0";
          "net.ipv4.conf.default.forwarding" = "0";
          "net.ipv6.conf.all.forwarding" = "0";
          "net.ipv6.conf.default.forwarding" = "0";

          # Privacy/security split.
          # See overrides file for details.
          "net.ipv4.tcp_timestamps" = "1";

          "dev.tty.ldisc_autoload" = "0";
          "fs.protected_fifos" = "2";
          "fs.protected_hardlinks" = "1";
          "fs.protected_regular" = "2";
          "fs.protected_symlinks" = "1";
          "fs.suid_dumpable" = "0";
          "kernel.dmesg_restrict" = "1";
          "kernel.kexec_load_disabled" = "1";
          "kernel.kptr_restrict" = "2";
          "kernel.perf_event_paranoid" = "3";
          "kernel.printk" = "3 3 3 3";
          "kernel.unprivileged_bpf_disabled" = "1";
          "net.core.bpf_jit_harden" = "2";
          "net.ipv4.conf.all.accept_redirects" = "0";
          "net.ipv4.conf.all.accept_source_route" = "0";
          "net.ipv4.conf.all.rp_filter" = "1";
          "net.ipv4.conf.all.secure_redirects" = "0";
          "net.ipv4.conf.all.send_redirects" = "0";
          "net.ipv4.conf.default.accept_redirects" = "0";
          "net.ipv4.conf.default.accept_source_route" = "0";
          "net.ipv4.conf.default.rp_filter" = "1";
          "net.ipv4.conf.default.secure_redirects" = "0";
          "net.ipv4.conf.default.send_redirects" = "0";
          "net.ipv4.icmp_echo_ignore_all" = "1";
          "net.ipv6.icmp_echo_ignore_all" = "1";
          "net.ipv4.tcp_dsack" = "0";
          "net.ipv4.tcp_fack" = "0";
          "net.ipv4.tcp_rfc1337" = "1";
          "net.ipv4.tcp_sack" = "0";
          "net.ipv4.tcp_syncookies" = "1";
          "net.ipv6.conf.all.accept_ra" = "0";
          "net.ipv6.conf.all.accept_redirects" = "0";
          "net.ipv6.conf.all.accept_source_route" = "0";
          "net.ipv6.conf.default.accept_redirects" = "0";
          "net.ipv6.conf.default.accept_source_route" = "0";
          "net.ipv6.default.accept_ra" = "0";
          "kernel.core_pattern" = "|/bin/false";
          "vm.mmap_rnd_bits" = "32";
          "vm.mmap_rnd_compat_bits" = "16";
          "vm.unprivileged_userfaultfd" = "0";
          "net.ipv4.icmp_ignore_bogus_error_responses" = "1";

          # enable ASLR
          # turn on protection and randomize stack, vdso page and mmap + randomize brk base address
          "kernel.randomize_va_space" = "2";

          # restrict perf subsystem usage (activity) further
          "kernel.perf_cpu_time_max_percent" = "1";
          "kernel.perf_event_max_sample_rate" = "1";

          # do not allow mmap in lower addresses
          "vm.mmap_min_addr" = "65536";

          # log packets with impossible addresses to kernel log
          # No active security benefit, just makes it easier to spot a DDOS/DOS by giving
          # extra logs
          "net.ipv4.conf.default.log_martians" = "1";
          "net.ipv4.conf.all.log_martians" = "1";

          # disable sending and receiving of shared media redirects
          # this setting overwrites net.ipv4.conf.all.secure_redirects
          # refer to RFC1620
          "net.ipv4.conf.default.shared_media" = "0";
          "net.ipv4.conf.all.shared_media" = "0";

          # always use the best local address for announcing local IP via ARP
          # Seems to be most restrictive option
          "net.ipv4.conf.default.arp_announce" = "2";
          "net.ipv4.conf.all.arp_announce" = "2";

          # reply only if the target IP address is local address configured on the incoming interface
          "net.ipv4.conf.default.arp_ignore" = "1";
          "net.ipv4.conf.all.arp_ignore" = "1";

          # drop Gratuitous ARP frames to prevent ARP poisoning
          # this can cause issues when ARP proxies are used in the network
          "net.ipv4.conf.default.drop_gratuitous_arp" = "1";
          "net.ipv4.conf.all.drop_gratuitous_arp" = "1";

          # ignore all ICMP echo and timestamp requests sent to broadcast/multicast
          "net.ipv4.icmp_echo_ignore_broadcasts" = "1";

          # number of Router Solicitations to send until assuming no routers are present
          "net.ipv6.conf.default.router_solicitations" = "0";
          "net.ipv6.conf.all.router_solicitations" = "0";

          # do not accept Router Preference from RA
          "net.ipv6.conf.default.accept_ra_rtr_pref" = "0";
          "net.ipv6.conf.all.accept_ra_rtr_pref" = "0";

          # learn prefix information in router advertisement
          "net.ipv6.conf.default.accept_ra_pinfo" = "0";
          "net.ipv6.conf.all.accept_ra_pinfo" = "0";

          # setting controls whether the system will accept Hop Limit settings from a router advertisement
          "net.ipv6.conf.default.accept_ra_defrtr" = "0";
          "net.ipv6.conf.all.accept_ra_defrtr" = "0";

          # router advertisements can cause the system to assign a global unicast address to an interface
          "net.ipv6.conf.default.autoconf" = "0";
          "net.ipv6.conf.all.autoconf" = "0";

          # number of neighbor solicitations to send out per address
          "net.ipv6.conf.default.dad_transmits" = "0";
          "net.ipv6.conf.all.dad_transmits" = "0";

          # number of global unicast IPv6 addresses can be assigned to each interface
          "net.ipv6.conf.default.max_addresses" = "1";
          "net.ipv6.conf.all.max_addresses" = "1";

          # enable IPv6 Privacy Extensions (RFC3041) and prefer the temporary address
          # https://grapheneos.org/features#wifi-privacy
          # GrapheneOS devs seem to believe it is relevant to use IPV6 privacy
          # extensions alongside MAC randomization, so that's why we do both
          "net.ipv6.conf.default.use_tempaddr" = l.mkForce "2";
          "net.ipv6.conf.all.use_tempaddr" = l.mkForce "2";

          # ignore all ICMPv6 echo requests
          "net.ipv6.icmp.echo_ignore_all" = "1";
          "net.ipv6.icmp.echo_ignore_anycast" = "1";
          "net.ipv6.icmp.echo_ignore_multicast" = "1";
        };
      };

      kernelParams = [
        # Requires all kernel modules to be signed. This prevents out-of-tree
        # kernel modules from working unless signed. See overrides.
        "module.sig_enforce=1"

        # May break some drivers, same reason as the above. Also breaks
        # hibernation. See overrides.
        "lockdown=confidentiality"

        # May prevent some systems from booting. See overrides.
        "efi=disable_early_pci_dma"

        # Forces DMA to go through IOMMU to mitigate some DMA attacks. See
        # overrides.
        "iommu.passthrough=0"

        # Apply relevant CPU exploit mitigations, and disable symmetric 
        # multithreading. May harm performance. See overrides.
        "mitigations=auto,nosmt"

        # Mitigates Meltdown, some KASLR bypasses. Hurts performance. See
        # overrides.
        "pti=on"

        # Gather more entropy on boot. Only works with the linux_hardened
        # patchset, but does nothing if using another kernel. Slows down boot
        # time by a bit. 
        "extra_latent_entropy"

        # Disables multilib/32 bit applications to reduce attack surface.
        # See overrides.
        "ia32_emulation=0"

        "slab_nomerge"
        "init_on_alloc=1"
        "init_on_free=1"
        "page_alloc.shuffle=1"
        "randomize_kstack_offset=on"
        "vsyscall=none"
        "debugfs=off"
        "oops=panic"
        "quiet"
        "loglevel=0"
        "random.trust_cpu=off"
        "random.trust_bootloader=off"
        "intel_iommu=on"
        "amd_iommu=force_isolation"
        "iommu=force"
        "iommu.strict=1"
      ];

      # Disable the editor in systemd-boot, the default bootloader for NixOS.
      # This prevents access to the root shell or otherwise weakening
      # security by tampering with boot parameters. If you use a different
      # boatloader, this does not provide anything. You may also want to
      # consider disabling similar functions in your choice of bootloader.
      loader.systemd-boot.editor = false;
    };
    environment.etc = {
      # Empty /etc/securetty to prevent root login on tty.
      securetty.text = ''
        # /etc/securetty: list of terminals on which root is allowed to login.
        # See securetty(5) and login(1).
      '';

      # Set machine-id to the Kicksecure machine-id, for privacy reasons.
      # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
      # so we don't have to worry about that.
      machine-id.text = ''
        b08dfa6083e7567a1921a715000001fb
      '';

      # Borrow Kicksecure banner/issue. 
      issue.source = fetchGhFile sources.issue;

      # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
      # by default for better git security.
      gitconfig.source = fetchGhFile sources.gitconfig;

      # Borrow Kicksecure bluetooth configuration for better bluetooth privacy
      # and security. Disables bluetooth automatically when not connected to
      # any device.
      "bluetooth/main.conf".source = l.mkForce (fetchGhFile sources.bluetooth);

      # Borrow Kicksecure and secureblue module blacklist.
      # "install "foobar" /bin/not-existent" prevents the module from being
      # loaded at all. "blacklist "foobar"" prevents the module from being
      # loaded automatically at boot, but it can still be loaded afterwards.
      "modprobe.d/nm-module-blacklist.conf".source = fetchGhFile sources.module-blacklist;
    };

    ### Filesystem hardening
    # Based on Kicksecure/security-misc's remount-secure
    # Kicksecure/security-misc
    # usr/bin/remount-secure - Last updated July 31st, 2024
    # Inapplicable:
    # /sys (Already hardened by default in NixOS)
    # /media, /mnt, /opt (Doesn't even exist on NixOS)
    # /var/tmp, /var/log (Covered by toplevel hardening on /var,)
    # Bind mounting /usr with nodev causes boot failure
    # Bind mounting /boot/efi at all causes complete system failure

    fileSystems = {
      # noexec on /home can be very inconvenient for desktops. See overrides.
      "/home" = {
        device = "/home";
        options = [
          "bind"
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      # You do not want to install applications here anyways.
      "/root" = {
        device = "/root";
        options = [
          "bind"
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      # Some applications may need to be executable in /tmp. See overrides.
      "/tmp" = {
        device = "/tmp";
        options = [
          "bind"
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      # noexec on /var(/lib) may cause breakage. See overrides.
      "/var" = {
        device = "/var";
        options = [
          "bind"
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      "/boot" = {
        device = "/boot";
        options = [
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      "/srv" = {
        device = "/srv";
        options = [
          "bind"
          "nosuid"
          "noexec"
          "nodev"
        ];
      };

      "/etc" = {
        device = "/etc";
        options = [
          "bind"
          "nosuid"
          "nodev"
        ];
      };
    };

    # Harden special filesystems while maintaining NixOS defaults as outlined
    # here:
    # https://github.com/NixOS/nixpkgs/blob/e2dd4e18cc1c7314e24154331bae07df76eb582f/nixos/modules/tasks/filesystems.nix
    boot.specialFileSystems = {
      # Add noexec to /dev/shm
      "/dev/shm" = {
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "noexec"
          "strictatime"
          "mode=1777"
          "size=${config.boot.devShmSize}"
        ];
      };

      # Add noexec to /run
      "/run" = {
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "noexec"
          "strictatime"
          "mode=755"
          "size=${config.boot.runSize}"
        ];
      };

      # Add noexec to /dev
      "/dev" = {
        fsType = "devtmpfs";
        options = [
          "nosuid"
          "noexec"
          "strictatime"
          "mode=755"
          "size=${config.boot.devSize}"
        ];
      };

      # Hide processes from other users except root, may cause breakage.
      # See overrides, in desktop section.
      "/proc" = {
        fsType = "proc";
        device = "proc";
        options = [
          "nosuid"
          "nodev"
          "noexec"
          "hidepid=2"
          "gid=proc"
        ];
      };
    };

    # Add "proc" group to whitelist /proc access and allow systemd-logind to view
    # /proc in order to unbreak it.
    users.groups.proc = { };
    systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];

    # Enables firewall. You may need to tweak your firewall rules depending on
    # your usecase. On a desktop, this shouldn't cause problems. 
    networking = {
      firewall = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
        enable = true;
      };
      networkmanager = {
        ethernet.macAddress = "random";
        wifi = {
          macAddress = "random";
          scanRandMacAddress = true;
        };
        # Enable IPv6 privacy extensions in NetworkManager.
        connectionConfig."ipv6.ip6-privacy" = l.mkDefault 2;
      };
    };

    # Enabling MAC doesn't magically make your system secure. You need to set up
    # policies yourself for it to be effective.
    security = {
      apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
      };

      pam = {
        loginLimits = [
          {
            domain = "*";
            item = "core";
            type = "hard";
            value = "0";
          }
        ];
        services = {
          # Increase hashing rounds for /etc/shadow; this doesn't automatically
          # rehash your passwords, you'll need to set passwords for your accounts
          # again for this to work.
          passwd.text = ''
            password required pam_unix.so sha512 shadow nullok rounds=65536
          '';
          # Enable PAM support for securetty, to prevent root login.
          # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
          login.text = l.mkDefault (
            l.mkBefore ''
              # Enable securetty support.
              auth       requisite  pam_nologin.so
              auth       requisite  pam_securetty.so
            ''
          );

          su.requireWheel = true;
          su-l.requireWheel = true;
          system-login.failDelay.delay = "4000000";
        };
      };
    };
    services = {
      # Disallow root login over SSH. Doesn't matter on systems without SSH.
      openssh.settings.PermitRootLogin = "no";

      # DNS connections will fail if not using a DNS server supporting DNSSEC.
      resolved.dnssec = "true";

      # Prevent BadUSB attacks, but requires whitelisting of USB devices. 
      usbguard.enable = true;
    };

    # Get extra entropy since we disabled hardware entropy sources
    # Read more about why at the following URLs:
    # https://github.com/smuellerDD/jitterentropy-rngd/issues/27
    # https://blogs.oracle.com/linux/post/rngd1
    services.jitterentropy-rngd.enable = true;
    boot.kernelModules = [ "jitterentropy_rng" ];

    # Don't store coredumps from systemd-coredump.
    systemd.coredump.extraConfig = l.mkDefault ''
      Storage=none
    '';

    # Enable IPv6 privacy extensions for systemd-networkd.
    systemd.network.config.networkConfig.IPv6PrivacyExtensions = l.mkDefault "kernel";

    systemd.tmpfiles.settings = {
      # Restrict permissions of /home/$USER so that only the owner of the
      # directory can access it (the user). systemd-tmpfiles also has the benefit
      # of recursively setting permissions too, with the "Z" option as seen below.
      "restricthome"."/home/*".Z.mode = "0700";

      # Make all files in /etc/nixos owned by root, and only readable by root.
      # /etc/nixos is not owned by root by default, and configuration files can
      # on occasion end up also not owned by root. This can be hazardous as files
      # that are included in the rebuild may be editable by unprivileged users,
      # so this mitigates that.
      "restrictetcnixos"."/etc/nixos/*".Z = {
        mode = "0000";
        user = "root";
        group = "root";
      };
    };

    # zram allows swapping to RAM by compressing memory. This reduces the chance
    # that sensitive data is written to disk, and eliminates it if zram is used
    # to completely replace swap to disk. Generally *improves* storage lifespan
    # and performance, there usually isn't a need to disable this.
    zramSwap.enable = true;

    # Limit access to nix to users with the "wheel" group. ("sudoers")
    nix.settings.allowed-users = l.mkForce [ "@wheel" ];
  })
];}
