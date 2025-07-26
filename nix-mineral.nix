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



# This is the main module for nix-mineral, containing the default configuration.

### CREDITS ###
# Please, see the README and give your thanks and support to the people and projects
# which have helped this project's development!



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
# 11.1 (Manual removal of SUID/SGID is manual)
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
# As of Decemeber 26, 2024, linux_hardened is up to date with mainline linux in
# unstable NixOS. However, it is cautioned that users regularly check the
# status of the linux_hardened package in NixOS, because it has been left
# unupdated for long periods of time in the past, which would be a severe
# security risk since an outdated kernel means the existence of many known
# vulnerabilities in the most privileged component of the operating system.
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

  cfg = config.nix-mineral;
in
{

  options.nix-mineral = {
    enable = l.mkOption {
      type = l.types.bool;
      default = false;
      description = ''
        Enable all nix-mineral defaults.
      '';
    };
    overrides = {
      compatibility = {
        allow-unsigned-modules = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow loading unsigned kernel modules.
          '';
        };
        allow-busmaster-bit = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Reenable the busmaster bit at boot.
          '';
        };
        allow-ip-forward = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Reenable ip forwarding.
          '';
        };
        no-lockdown = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable Linux Kernel Lockdown.
          '';
        };
      };
      desktop = {
        allow-multilib = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Reenable support for 32 bit applications.
          '';
        };
        doas-sudo-wrapper = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Enable doas-sudo wrapper, with nano to utilize rnano as a "safe"
            editor for editing as root.
          '';
        };
        hideproc-ptraceable = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow processes that can ptrace a process to read its corresponding /proc
            information.
          '';
        };
        hideproc-off = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable access restriction on /proc.
            Fix Gnome/Wayland.
          '';
        };
        home-exec = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow programs to execute in /home.
          '';
        };
        skip-restrict-home-permission = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable recursively restricting permisions of /home directories,
            as this can takes several minutes on large home directories.
          '';
        };
        nix-allow-all = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow all users to use nix.
          '';
        };
        tmp-exec = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow executing programs in /tmp.
          '';
        };
        usbguard-gnome-integration = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Enable USBGuard dbus daemon and polkit rules for integration with GNOME
            Shell.
          '';
        };
        var-lib-exec = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Allow executing programs in /var/lib.
          '';
        };
      };
      performance = {
        allow-smt = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Reenable symmetric multithreading.
          '';
        };
        iommu-passthrough = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Enable bypassing the IOMMU for direct memory access.
          '';
        };
        no-mitigations = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable all CPU vulnerability mitigations.
          '';
        };
        no-pti = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable page table isolation.
          '';
        };
      };
      security = {
        disable-bluetooth-kmodules = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable bluetooth related kernel modules.
          '';
        };
        disable-intelme-kmodules = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable Intel ME related kernel modules and partially disable ME interface.
          '';
        };
        disable-amd-iommu-forced-isolation = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Do not set amd_iommu=force_isolation kernel parameter.
            Workaround hanging issue on linux kernel 6.13.
          '';
        };
        lock-root = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Lock the root user.
          '';
        };
        minimize-swapping = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Reduce frequency of swapping to bare minimum.
          '';
        };
        sysrq-sak = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Enable Secure Attention Key with the sysrq key.
          '';
        };
      };
      software-choice = {
        doas-no-sudo = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Replace sudo with doas.
          '';
        };
        no-firewall = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Disable default firewall as chosen by nix-mineral.
          '';
        };
        secure-chrony = l.mkOption {
          type = l.types.bool;
          default = false;
          description = ''
            Replace systemd-timesyncd with chrony for NTP, and configure chrony for NTS
            and to use the seccomp filter for security.
          '';
        };
      };
    };
  };

  config = l.mkIf cfg.enable (l.mkMerge [

    # Main module

    {
      boot = {
        kernel = {
          sysctl = {
            # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.

            # Yama restricts ptrace, which allows processes to read and modify the
            # memory of other processes. This has obvious security implications.
            # Default value is 1, to only allow parent processes to ptrace child
            # processes. May be modified to restrict ptrace further.
            # See overrides.
            "kernel.yama.ptrace_scope" = l.mkDefault "1";

            # Disables magic sysrq key. See overrides file regarding SAK (Secure
            # attention key).
            "kernel.sysrq" = l.mkDefault "0";

            # Disable binfmt. Breaks Roseta, among other applications.
            # See overrides file and https://en.wikipedia.org/wiki/Binfmt_misc for more info.
            "fs.binfmt_misc.status" = l.mkDefault "0";

            # Disable io_uring. May be desired for Proxmox, but is responsible
            # for many vulnerabilities and is disabled on Android + ChromeOS.
            # See overrides file.
            "kernel.io_uring_disabled" = l.mkDefault "2";

            # Disable ip forwarding to reduce attack surface. May be needed for
            # VM networking. See overrides file.
            "net.ipv4.ip_forward" = l.mkDefault "0";
            "net.ipv4.conf.all.forwarding" = l.mkOverride 900 "0";
            "net.ipv4.conf.default.forwarding" = l.mkDefault "0";
            "net.ipv6.conf.all.forwarding" = l.mkDefault "0";
            "net.ipv6.conf.default.forwarding" = l.mkDefault "0";

            # Privacy/security split.
            # By default, nix-mineral enables
            # tcp-timestamps. Disabling prevents leaking system time, enabling protects
            # against wrapped sequence numbers and improves performance.
            #
            # Read more about the issue here:
            # URL: (In favor of disabling): https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
            # URL: (In favor of enabling): https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
            "net.ipv4.tcp_timestamps" = l.mkDefault "1";

            "dev.tty.ldisc_autoload" = l.mkDefault "0";
            "fs.protected_fifos" = l.mkDefault "2";
            "fs.protected_hardlinks" = l.mkDefault "1";
            "fs.protected_regular" = l.mkDefault "2";
            "fs.protected_symlinks" = l.mkDefault "1";
            "fs.suid_dumpable" = l.mkDefault "0";
            "kernel.dmesg_restrict" = l.mkDefault "1";
            "kernel.kexec_load_disabled" = l.mkOverride 900 "1";
            "kernel.kptr_restrict" = l.mkOverride 900 "2";
            "kernel.perf_event_paranoid" = l.mkDefault "3";
            "kernel.printk" = l.mkOverride 900 "3 3 3 3";
            "kernel.unprivileged_bpf_disabled" = l.mkDefault "1";
            "net.core.bpf_jit_harden" = l.mkDefault "2";

            # Disable ICMP redirects to prevent some MITM attacks
            # See https://askubuntu.com/questions/118273/what-are-icmp-redirects-and-should-they-be-blocked
            "net.ipv4.conf.all.accept_redirects" = l.mkOverride 900 "0";
            "net.ipv4.conf.default.accept_redirects" = l.mkOverride 900 "0";
            "net.ipv4.conf.all.send_redirects" = l.mkOverride 900 "0";
            "net.ipv4.conf.default.send_redirects" = l.mkOverride 900 "0";
            "net.ipv6.conf.all.accept_redirects" = l.mkOverride 900 "0";
            "net.ipv6.conf.default.accept_redirects" = l.mkOverride 900 "0";

            # Use secure ICMP redirects by default. Helpful if ICMP redirects are
            # reenabled only.
            "net.ipv4.conf.all.secure_redirects" = l.mkOverride 900 "1";
            "net.ipv4.conf.default.secure_redirects" = l.mkOverride 900 "1";

            "net.ipv4.conf.all.accept_source_route" = l.mkDefault "0";
            "net.ipv4.conf.all.rp_filter" = l.mkOverride 900 "1";
            "net.ipv4.conf.default.accept_source_route" = l.mkDefault "0";
            "net.ipv4.conf.default.rp_filter" = l.mkOverride 900 "1";
            "net.ipv4.icmp_echo_ignore_all" = l.mkDefault "1";
            "net.ipv6.icmp_echo_ignore_all" = l.mkDefault "1";
            "net.ipv4.tcp_dsack" = l.mkDefault "0";
            "net.ipv4.tcp_fack" = l.mkDefault "0";
            "net.ipv4.tcp_rfc1337" = l.mkDefault "1";
            "net.ipv4.tcp_sack" = l.mkDefault "0";
            "net.ipv4.tcp_syncookies" = l.mkDefault "1";
            "net.ipv6.conf.all.accept_ra" = l.mkDefault "0";
            "net.ipv6.conf.all.accept_source_route" = l.mkDefault "0";
            "net.ipv6.conf.default.accept_source_route" = l.mkDefault "0";
            "net.ipv6.default.accept_ra" = l.mkDefault "0";
            "kernel.core_pattern" = l.mkDefault "|/bin/false";
            "vm.mmap_rnd_bits" = l.mkDefault "32";
            "vm.mmap_rnd_compat_bits" = l.mkDefault "16";
            "vm.unprivileged_userfaultfd" = l.mkDefault "0";
            "net.ipv4.icmp_ignore_bogus_error_responses" = l.mkDefault "1";

            # enable ASLR
            # turn on protection and randomize stack, vdso page and mmap + randomize brk base address
            "kernel.randomize_va_space" = l.mkDefault "2";

            # restrict perf subsystem usage (activity) further
            "kernel.perf_cpu_time_max_percent" = l.mkDefault "1";
            "kernel.perf_event_max_sample_rate" = l.mkDefault "1";

            # do not allow mmap in lower addresses
            "vm.mmap_min_addr" = l.mkDefault "65536";

            # log packets with impossible addresses to kernel log
            # No active security benefit, just makes it easier to spot a DDOS/DOS by giving
            # extra logs
            "net.ipv4.conf.default.log_martians" = l.mkOverride 900 "1";
            "net.ipv4.conf.all.log_martians" = l.mkOverride 900 "1";

            # disable sending and receiving of shared media redirects
            # this setting overwrites net.ipv4.conf.all.secure_redirects
            # refer to RFC1620
            "net.ipv4.conf.default.shared_media" = l.mkDefault "0";
            "net.ipv4.conf.all.shared_media" = l.mkDefault "0";

            # always use the best local address for announcing local IP via ARP
            # Seems to be most restrictive option
            "net.ipv4.conf.default.arp_announce" = l.mkDefault "2";
            "net.ipv4.conf.all.arp_announce" = l.mkDefault "2";

            # reply only if the target IP address is local address configured on the incoming interface
            "net.ipv4.conf.default.arp_ignore" = l.mkDefault "1";
            "net.ipv4.conf.all.arp_ignore" = l.mkDefault "1";

            # drop Gratuitous ARP frames to prevent ARP poisoning
            # this can cause issues when ARP proxies are used in the network
            "net.ipv4.conf.default.drop_gratuitous_arp" = l.mkDefault "1";
            "net.ipv4.conf.all.drop_gratuitous_arp" = l.mkDefault "1";

            # ignore all ICMP echo and timestamp requests sent to broadcast/multicast
            "net.ipv4.icmp_echo_ignore_broadcasts" = l.mkOverride 900 "1";

            # number of Router Solicitations to send until assuming no routers are present
            "net.ipv6.conf.default.router_solicitations" = l.mkDefault "0";
            "net.ipv6.conf.all.router_solicitations" = l.mkDefault "0";

            # do not accept Router Preference from RA
            "net.ipv6.conf.default.accept_ra_rtr_pref" = l.mkDefault "0";
            "net.ipv6.conf.all.accept_ra_rtr_pref" = l.mkDefault "0";

            # learn prefix information in router advertisement
            "net.ipv6.conf.default.accept_ra_pinfo" = l.mkDefault "0";
            "net.ipv6.conf.all.accept_ra_pinfo" = l.mkDefault "0";

            # setting controls whether the system will accept Hop Limit settings from a router advertisement
            "net.ipv6.conf.default.accept_ra_defrtr" = l.mkDefault "0";
            "net.ipv6.conf.all.accept_ra_defrtr" = l.mkDefault "0";

            # router advertisements can cause the system to assign a global unicast address to an interface
            "net.ipv6.conf.default.autoconf" = l.mkDefault "0";
            "net.ipv6.conf.all.autoconf" = l.mkDefault "0";

            # number of neighbor solicitations to send out per address
            "net.ipv6.conf.default.dad_transmits" = l.mkDefault "0";
            "net.ipv6.conf.all.dad_transmits" = l.mkDefault "0";

            # number of global unicast IPv6 addresses can be assigned to each interface
            "net.ipv6.conf.default.max_addresses" = l.mkDefault "1";
            "net.ipv6.conf.all.max_addresses" = l.mkDefault "1";

            # enable IPv6 Privacy Extensions (RFC3041) and prefer the temporary address
            # https://grapheneos.org/features#wifi-privacy
            # GrapheneOS devs seem to believe it is relevant to use IPV6 privacy
            # extensions alongside MAC randomization, so that's why we do both
            # Commented, as this is already explicitly defined by default in NixOS
            # "net.ipv6.conf.default.use_tempaddr" = l.mkForce "2";
            # "net.ipv6.conf.all.use_tempaddr" = l.mkForce "2";

            # ignore all ICMPv6 echo requests
            "net.ipv6.icmp.echo_ignore_all" = l.mkDefault "1";
            "net.ipv6.icmp.echo_ignore_anycast" = l.mkDefault "1";
            "net.ipv6.icmp.echo_ignore_multicast" = l.mkDefault "1";
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
          "iommu=force"
          "iommu.strict=1"
        ] ++ lib.optional (!cfg.overrides.security.disable-amd-iommu-forced-isolation)
          "amd_iommu=force_isolation";

        # Disable the editor in systemd-boot, the default bootloader for NixOS.
        # This prevents access to the root shell or otherwise weakening
        # security by tampering with boot parameters. If you use a different
        # boatloader, this does not provide anything. You may also want to
        # consider disabling similar functions in your choice of bootloader.
        loader.systemd-boot.editor = l.mkDefault false;
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
        issue.source = (fetchGhFile sources.issue);

        # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
        # by default for better git security.
        gitconfig.source = (fetchGhFile sources.gitconfig);

        # Borrow Kicksecure bluetooth configuration for better bluetooth privacy
        # and security. Disables bluetooth automatically when not connected to
        # any device.
        "bluetooth/main.conf".source = l.mkForce (fetchGhFile sources.bluetooth);

        # Borrow Kicksecure module blacklist.
        # "install "foobar" /bin/not-existent" prevents the module from being
        # loaded at all. "blacklist "foobar"" prevents the module from being
        # loaded automatically at boot, but it can still be loaded afterwards.
        "modprobe.d/nm-module-blacklist.conf".source = (fetchGhFile sources.module-blacklist);
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
          device = l.mkDefault "/home";
          options = [
            "bind"
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        # You do not want to install applications here anyways.
        "/root" = {
          device = l.mkDefault "/root";
          options = [
            "bind"
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        # Some applications may need to be executable in /tmp. See overrides.
        "/tmp" = {
          device = l.mkDefault "/tmp";
          options = [
            "bind"
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        # noexec on /var(/lib) may cause breakage. See overrides.
        "/var" = {
          device = l.mkDefault "/var";
          options = [
            "bind"
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        "/boot" = lib.mkIf (!config.boot.isContainer) {
          options = [
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        "/srv" = {
          device = l.mkDefault "/srv";
          options = [
            "bind"
            "nosuid"
            "noexec"
            "nodev"
          ];
        };

        "/etc" = lib.mkIf (!config.boot.isContainer) {
          device = l.mkDefault "/etc";
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
          options = [
            "noexec"
          ];
        };

        # Add noexec to /run
        "/run" = {
          options = [
            "noexec"
          ];
        };

        # Add noexec to /dev
        "/dev" = {
          options = [
            "noexec"
          ];
        };

        # Hide processes from other users except root, may cause breakage.
        # See overrides, in desktop section.
        "/proc" = {
          device = l.mkDefault "proc";
          options = [
            "hidepid=2"
            "gid=${toString config.users.groups.proc.gid}"
          ];
        };
      };

      # Add "proc" group to whitelist /proc access and allow systemd-logind to view
      # /proc in order to unbreak it, as well as to user@ for similar reasons.
      # See https://github.com/systemd/systemd/issues/12955, and https://github.com/Kicksecure/security-misc/issues/208
      users.groups.proc.gid = l.mkDefault config.ids.gids.proc;
      systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];
      systemd.services."user@".serviceConfig.SupplementaryGroups = [ "proc" ];

      # Enables firewall. You may need to tweak your firewall rules depending on
      # your usecase. On a desktop, this shouldn't cause problems. 
      networking = {
        firewall = {
          allowedTCPPorts = l.mkDefault [ ];
          allowedUDPPorts = l.mkDefault [ ];
          enable = l.mkDefault true;
        };
        networkmanager = {
          ethernet.macAddress = l.mkDefault "random";
          wifi = {
            macAddress = l.mkDefault "random";
            scanRandMacAddress = l.mkDefault true;
          };
          # Enable IPv6 privacy extensions in NetworkManager.
          connectionConfig."ipv6.ip6-privacy" = l.mkDefault 2;
        };
      };

      # Enabling MAC doesn't magically make your system secure. You need to set up
      # policies yourself for it to be effective.
      security = {
        apparmor = {
          enable = l.mkDefault true;
          killUnconfinedConfinables = l.mkDefault true;
        };

        pam = {
          loginLimits = [
            {
              domain = l.mkDefault "*";
              item = l.mkDefault "core";
              type = l.mkDefault "hard";
              value = l.mkDefault "0";
            }
          ];
          services = {
            # Increase hashing rounds for /etc/shadow; this doesn't automatically
            # rehash your passwords, you'll need to set passwords for your accounts
            # again for this to work.
            passwd.rules.password."unix".settings.rounds = l.mkDefault 65536;
            # Enable PAM support for securetty, to prevent root login.
            # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
            login.rules.auth = { 
              "nologin" = {
                enable = l.mkDefault true;
                order = l.mkDefault 0;
                control = l.mkDefault "requisite";
                modulePath = l.mkDefault "${config.security.pam.package}/lib/security/pam_nologin.so";
              };
              "securetty" = {
                enable = l.mkDefault true;
                order = l.mkDefault 1;
                control = l.mkDefault "requisite";
                modulePath = l.mkDefault "${config.security.pam.package}/lib/security/pam_securetty.so";
              };
            };

            su.requireWheel = l.mkDefault true;
            su-l.requireWheel = l.mkDefault true;
            system-login.failDelay.delay = l.mkDefault "4000000";
          };
        };
      };
      services = {
        # Disallow root login over SSH. Doesn't matter on systems without SSH.
        openssh.settings.PermitRootLogin = l.mkDefault "no";

        # DNS connections will fail if not using a DNS server supporting DNSSEC.
        resolved.dnssec = l.mkDefault "true";
      };

      # Get extra entropy since we disabled hardware entropy sources
      # Read more about why at the following URLs:
      # https://github.com/smuellerDD/jitterentropy-rngd/issues/27
      # https://blogs.oracle.com/linux/post/rngd1
      services.jitterentropy-rngd.enable = l.mkDefault (!config.boot.isContainer);
      boot.kernelModules = [ "jitterentropy_rng" ];

      # Don't store coredumps from systemd-coredump.
      systemd.coredump.extraConfig = ''
        Storage=none
      '';

      # Enable IPv6 privacy extensions for systemd-networkd.
      systemd.network.config.networkConfig.IPv6PrivacyExtensions = l.mkDefault "kernel";

      systemd.tmpfiles.settings = {
        # Make all files in /etc/nixos owned by root, and only readable by root.
        # /etc/nixos is not owned by root by default, and configuration files can
        # on occasion end up also not owned by root. This can be hazardous as files
        # that are included in the rebuild may be editable by unprivileged users,
        # so this mitigates that.
        "restrictetcnixos"."/etc/nixos/*".Z = {
          mode = l.mkDefault "0000";
          user = l.mkDefault "root";
          group = l.mkDefault "root";
        };
      } // lib.optionalAttrs (!cfg.overrides.desktop.skip-restrict-home-permission) {
        # Restrict permissions of /home/$USER so that only the owner of the
        # directory can access it (the user). systemd-tmpfiles also has the benefit
        # of recursively setting permissions too, with the "Z" option as seen below.
        "restricthome"."/home/*".Z.mode = l.mkDefault "~0700";
      };

      # zram allows swapping to RAM by compressing memory. This reduces the chance
      # that sensitive data is written to disk, and eliminates it if zram is used
      # to completely replace swap to disk. Generally *improves* storage lifespan
      # and performance, there usually isn't a need to disable this.
      zramSwap.enable = l.mkDefault true;

      # Limit access to nix to users with the "wheel" group. ("sudoers")
      nix.settings.allowed-users = l.mkDefault [ "@wheel" ];
    }

    # Compatibility

    (l.mkIf cfg.overrides.compatibility.allow-unsigned-modules {
      boot.kernelParams = l.mkOverride 100 [ "module.sig_enforce=0" ];
    })

    (l.mkIf cfg.overrides.compatibility.allow-busmaster-bit {
      boot.kernelParams = l.mkOverride 100 [ "efi=no_disable_early_pci_dma" ];
    })

    (l.mkIf cfg.overrides.compatibility.allow-ip-forward {
      boot.kernel.sysctl."net.ipv4.ip_forward" = l.mkForce "1";
      boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = l.mkForce "1";
      boot.kernel.sysctl."net.ipv4.conf.default.forwarding" = l.mkForce "1";
      boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = l.mkForce "1";
      boot.kernel.sysctl."net.ipv6.conf.default.forwarding" = l.mkForce "1";
    })

    (l.mkIf cfg.overrides.compatibility.no-lockdown {
      boot.kernelParams = l.mkOverride 100 [ "lockdown=" ];
    })

    # Desktop

    (l.mkIf cfg.overrides.desktop.allow-multilib {
      boot.kernelParams = l.mkOverride 100 [ "ia32_emulation=1" ];
    })

    (l.mkIf cfg.overrides.desktop.doas-sudo-wrapper {
      environment.systemPackages = (with pkgs; [
        (writeScriptBin "sudo" ''exec ${l.getExe doas} "$@"'')
        (writeScriptBin "sudoedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
        (writeScriptBin "doasedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
      ]);
    })

    (l.mkIf cfg.overrides.desktop.hideproc-ptraceable {
      boot.specialFileSystems."/proc" = {
        options = l.mkForce [
          "nosuid"
          "nodev"
          "noexec"
          "hidepid=4"
          "gid=${toString config.users.groups.proc.gid}"
        ];
      };
    })

    (l.mkIf cfg.overrides.desktop.hideproc-off {
      boot.specialFileSystems."/proc" = {
        options = l.mkForce [
          "nosuid"
          "nodev"
          "noexec"
          "gid=${toString config.users.groups.proc.gid}"
        ];
      };
    })

    (l.mkIf cfg.overrides.desktop.home-exec {
      fileSystems."/home" = {
        device = l.mkForce "/home";
        options = l.mkForce [
          "bind"
          "nosuid"
          "exec"
          "nodev"
        ];
      };
    })

    (l.mkIf cfg.overrides.desktop.nix-allow-all { nix.settings.allowed-users = l.mkForce [ "*" ]; })

    (l.mkIf cfg.overrides.desktop.tmp-exec {
      fileSystems."/tmp" = {
        device = l.mkForce "/tmp";
        options = l.mkForce [
          "bind"
          "nosuid"
          "exec"
          "nodev"
        ];
      };
    })

    (l.mkIf cfg.overrides.desktop.usbguard-gnome-integration {
      services.usbguard.dbus.enable = l.mkForce true;
      security.polkit = {
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if ((action.id == "org.usbguard.Policy1.listRules" ||
                 action.id == "org.usbguard.Policy1.appendRule" ||
                 action.id == "org.usbguard.Policy1.removeRule" ||
                 action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
                 action.id == "org.usbguard.Devices1.listDevices" ||
                 action.id == "org.usbguard1.getParameter" ||
                 action.id == "org.usbguard1.setParameter") &&
                 subject.active == true && subject.local == true &&
                 subject.isInGroup("wheel")) { return polkit.Result.YES; }
          });
        '';
      };
    })

    (l.mkIf cfg.overrides.desktop.var-lib-exec {
      fileSystems."/var/lib" = {
        device = l.mkForce "/var/lib";
        options = l.mkForce [
          "bind"
          "nosuid"
          "exec"
          "nodev"
        ];
      };
    })

    # Performance

    (l.mkIf cfg.overrides.performance.allow-smt {
      boot.kernelParams = l.mkOverride 100 [ "mitigations=auto" ];
    })

    (l.mkIf cfg.overrides.performance.iommu-passthrough {
      boot.kernelParams = l.mkOverride 100 [ "iommu.passthrough=1" ];
    })

    (l.mkIf cfg.overrides.performance.no-mitigations {
      boot.kernelParams = l.mkOverride 100 [ "mitigations=off" ];
    })

    (l.mkIf cfg.overrides.performance.no-pti { boot.kernelParams = l.mkOverride 100 [ "pti=off" ]; })

    # Security

    (l.mkIf cfg.overrides.security.disable-bluetooth-kmodules {
      environment.etc."modprobe.d/nm-disable-bluetooth.conf" = {
        text = ''
          install bluetooth /usr/bin/disabled-bluetooth-by-security-misc
          install bluetooth_6lowpan  /usr/bin/disabled-bluetooth-by-security-misc
          install bt3c_cs /usr/bin/disabled-bluetooth-by-security-misc
          install btbcm /usr/bin/disabled-bluetooth-by-security-misc
          install btintel /usr/bin/disabled-bluetooth-by-security-misc
          install btmrvl /usr/bin/disabled-bluetooth-by-security-misc
          install btmrvl_sdio /usr/bin/disabled-bluetooth-by-security-misc
          install btmtk /usr/bin/disabled-bluetooth-by-security-misc
          install btmtksdio /usr/bin/disabled-bluetooth-by-security-misc
          install btmtkuart /usr/bin/disabled-bluetooth-by-security-misc
          install btnxpuart /usr/bin/disabled-bluetooth-by-security-misc
          install btqca /usr/bin/disabled-bluetooth-by-security-misc
          install btrsi /usr/bin/disabled-bluetooth-by-security-misc
          install btrtl /usr/bin/disabled-bluetooth-by-security-misc
          install btsdio /usr/bin/disabled-bluetooth-by-security-misc
          install btusb /usr/bin/disabled-bluetooth-by-security-misc
          install virtio_bt /usr/bin/disabled-bluetooth-by-security-misc
        '';
      };
    })

    (l.mkIf cfg.overrides.security.disable-intelme-kmodules {
      environment.etc."modprobe.d/nm-disable-intelme-kmodules.conf" = {
        text = ''
          install mei /usr/bin/disabled-intelme-by-security-misc
          install mei-gsc /usr/bin/disabled-intelme-by-security-misc
          install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
          install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
          install mei-me /usr/bin/disabled-intelme-by-security-misc
          install mei_phy /usr/bin/disabled-intelme-by-security-misc
          install mei_pxp /usr/bin/disabled-intelme-by-security-misc
          install mei-txe /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc /usr/bin/disabled-intelme-by-security-misc
          install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
          install mei_wdt /usr/bin/disabled-intelme-by-security-misc
          install microread_mei /usr/bin/disabled-intelme-by-security-misc
        '';
      };
    })

    (l.mkIf cfg.overrides.security.lock-root {
      users = {
        users = {
          root = {
            hashedPassword = l.mkDefault "!";
          };
        };
      };
    })

    (l.mkIf cfg.overrides.security.minimize-swapping {
      boot.kernel.sysctl."vm.swappiness" = l.mkForce "1";
    })

    (l.mkIf cfg.overrides.security.sysrq-sak { boot.kernel.sysctl."kernel.sysrq" = l.mkForce "4"; })

    # Software Choice

    (l.mkIf cfg.overrides.software-choice.doas-no-sudo {
      security.sudo.enable = l.mkDefault false;
      security.doas = {
        enable = l.mkDefault true;
        extraRules = [
          {
            keepEnv = l.mkDefault true;
            persist = l.mkDefault true;
            users = l.mkDefault [ "user" ];
          }
        ];
      };
    })

    (l.mkIf cfg.overrides.software-choice.no-firewall { networking.firewall.enable = l.mkForce false; })

    (l.mkIf cfg.overrides.software-choice.secure-chrony {
      services.timesyncd = {
        enable = l.mkDefault false;
      };
      services.chrony = {
        enable = l.mkDefault true;

        extraFlags = l.mkDefault [
          "-F 1"
          "-r"
        ];
        # Enable seccomp filter for chronyd (-F 1) and reload server history on
        # restart (-r). The -r flag is added to match GrapheneOS's original
        # chronyd configuration.

        enableRTCTrimming = l.mkDefault false;
        # Disable 'rtcautotrim' so that 'rtcsync' can be used instead. Either
        # this or 'rtcsync' must be disabled to complete a successful rebuild,
        # or an error will be thrown due to these options conflicting with
        # eachother.

        servers = l.mkDefault [ ];
        # Since servers are declared by the fetched chrony config, set the
        # NixOS option to [ ] to prevent the default values from interfering.

        initstepslew.enabled = l.mkDefault false;
        # Initstepslew "is deprecated in favour of the makestep directive"
        # according to:
        # https://chrony-project.org/doc/4.6/chrony.conf.html#initstepslew.
        # The fetched chrony config already has makestep enabled, so
        # initstepslew is disabled (it is enabled by default).

        # The below config is borrowed from GrapheneOS server infrastructure.
        # It enables NTS to secure NTP requests, among some other useful
        # settings.

        extraConfig = ''
          ${builtins.readFile (fetchGhFile sources.chrony)}
          leapseclist ${pkgs.tzdata}/share/zoneinfo/leap-seconds.list
        '';
        # Override the leapseclist path with the NixOS-compatible path to
        # leap-seconds.list using the tzdata package. This is necessary because
        # NixOS doesn't use standard FHS paths like /usr/share/zoneinfo.
      };
    })
  ]);
}
