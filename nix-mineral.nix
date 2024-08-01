# This is the main module for nix-mineral, containing the default configuration.

# Primarily sourced was madaidan's Linux Hardening Guide. See for details: 
# URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html
# Archive: https://web.archive.org/web/20220320000126/https://madaidans-insecurities.github.io/guides/linux-hardening.html 

# Additionally sourced is privsec's Desktop Linux Hardening:
# URL: https://privsec.dev/posts/linux/desktop-linux-hardening/
# Archive: https://web.archive.org/web/20240629135847/https://privsec.dev/posts/linux/desktop-linux-hardening/#kernel

# Bluetooth configuration and module blacklist was borrowed from Kicksecure's 
# security-misc:
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

({ config, lib, pkgs, ... }:

(with lib; {

# Imports the overrides file, which should be in the same directory as this.
imports = [ ./nm-overrides.nix ];

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
         "net.ipv6.conf.default.use_tempaddr" = mkForce "2";
         "net.ipv6.conf.all.use_tempaddr" = mkForce "2";

         # ignore all ICMPv6 echo requests
         "net.ipv6.icmp.echo_ignore_all" = "1";
         "net.ipv6.icmp.echo_ignore_anycast" = "1";
         "net.ipv6.icmp.echo_ignore_multicast" = "1";
      };
    };
    
    kernelParams = [
      # Requires all kernel modules to be signed. This prevents out-of-tree
      # kernel modules from working unless signed. See overrides.
      ("module.sig_enforce=1")
      
      # May break some drivers, same reason as the above. Also breaks
      # hibernation. See overrides.
      ("lockdown=confidentiality")

      # May prevent some systems from booting. See overrides.
      ("efi=disable_early_pci_dma") 

      # Forces DMA to go through IOMMU to mitigate some DMA attacks. See
      # overrides.
      ("iommu.passthrough=0") 

      # Apply relevant CPU exploit mitigations, and disable symmetric 
      # multithreading. May harm performance. See overrides.
      ("mitigations=auto,nosmt") 

      # Mitigates Meltdown, some KASLR bypasses. Hurts performance. See
      # overrides.
      ("pti=on")
      
      # Gather more entropy on boot. Only works with the linux_hardened
      # patchset, but does nothing if using another kernel. Slows down boot
      # time by a bit. 
      ("extra_latent_entropy")

      # Disables multilib/32 bit applications to reduce attack surface.
      # See overrides.
      ("ia32_emulation=0")

      ("slab_nomerge")
      ("init_on_alloc=1")
      ("init_on_free=1")
      ("page_alloc.shuffle=1")
      ("randomize_kstack_offset=on")      
      ("vsyscall=none")
      ("debugfs=off")
      ("oops=panic")
      ("quiet")
      ("loglevel=0")
      ("random.trust_cpu=off")
      ("random.trust_bootloader=off")
      ("intel_iommu=on")
      ("amd_iommu=force_isolation")
      ("iommu=force")
      ("iommu.strict=1")
    ];

    # Disable the editor in systemd-boot, the default bootloader for NixOS.
    # This prevents access to the root shell or otherwise weakening
    # security by tampering with boot parameters. If you use a different
    # boatloader, this does not provide anything. You may also want to
    # consider disabling similar functions in your choice of bootloader.
    loader = { systemd-boot = { editor = false; }; };

  };
  environment = {    
    etc = {
      # Empty /etc/securetty to prevent root login on tty.
      securetty = {
        text = ''
          # /etc/securetty: list of terminals on which root is allowed to login.
          # See securetty(5) and login(1).
        '';
      };

      # Set machine-id to the Kicksecure machine-id, for privacy reasons.
      # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
      # so we don't have to worry about that.
      machine-id = {
        text = ''
          b08dfa6083e7567a1921a715000001fb
        '';
      };

      # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
      # by default for better git security.
      gitconfig = {
        text = ''
          ### Kicksecure/security-misc
          ### etc/gitconfig - Last updated August 1st, 2024

          ## Copyright (C) 2024 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          ## Lines starting with a hash symbol ('#') are comments.
          ## https://github.com/Kicksecure/security-misc/issues/225

          [core]
          ## https://github.com/git/git/security/advisories/GHSA-8prw-h3cq-mghm
            symlinks = false

          ## https://forums.whonix.org/t/git-users-enable-fsck-by-default-for-better-security/2066
          [transfer]
            fsckobjects = true
          [fetch]
            fsckobjects = true
          [receive]
            fsckobjects = true

          ## Generally a good idea but too intrusive to enable by default.
          ## Listed here as suggestions what users should put into their ~/.gitconfig
          ## file.

          ## Not enabled by default because it requires essential knowledge about OpenPG
          ## and an already existing local signing key. Otherwise would prevent all new
          ## commits.
          #[commit]
          #	gpgsign = true

          ## Not enabled by default because it would break the 'git merge' command for
          ## unsigned commits and require the '--no-verify-signature' command line
          ## option.
          #[merge]
          #	verifySignatures = true

          ## Not enabled by default because it would break for users who are not having
          ## an account at the git server and having added a SSH public key.
          #[url "ssh://git@github.com/"]
          #	insteadOf = https://github.com/
        '';
      };

      # Borrow Kicksecure bluetooth configuration for better bluetooth privacy
      # and security. Disables bluetooth automatically when not connected to
      # any device.
      "bluetooth/main.conf" = mkForce {
        text = ''
          ### Kicksecure/security-misc
          ### etc/bluetooth/30_security-misc.conf - Last updated July 29th, 2024

          ## Copyright (C) 2023 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          [General]
          # How long to stay in pairable mode before going back to non-discoverable
          # The value is in seconds. Default is 0.
          # 0 = disable timer, i.e. stay pairable forever
          PairableTimeout = 30

          # How long to stay in discoverable mode before going back to non-discoverable
          # The value is in seconds. Default is 180, i.e. 3 minutes.
          # 0 = disable timer, i.e. stay discoverable forever
          DiscoverableTimeout = 30

          # Maximum number of controllers allowed to be exposed to the system.
          # Default=0 (unlimited)
          MaxControllers=1

          # How long to keep temporary devices around
          # The value is in seconds. Default is 30.
          # 0 = disable timer, i.e. never keep temporary devices
          TemporaryTimeout = 0

          [Policy]
          # AutoEnable defines option to enable all controllers when they are found.
          # This includes adapters present on start as well as adapters that are plugged
          # in later on. Defaults to 'true'.
          AutoEnable=false

          # network/on: A device will only accept advertising packets from peer
          # devices that contain private addresses. It may not be compatible with some
          # legacy devices since it requires the use of RPA(s) all the time.
          Privacy=network/on 
        '';
      };

      # Borrow Kicksecure and secureblue module blacklist.
      # "install "foobar" /bin/not-existent" prevents the module from being
      # loaded at all. "blacklist "foobar"" prevents the module from being
      # loaded automatically at boot, but it can still be loaded afterwards.
      "modprobe.d/nm-module-blacklist.conf" = {
        text = ''
          ### Kicksecure/security-misc
          ### etc/modprobe.d/30_security-misc_disable.conf - Last updated July 31st, 2024

          ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          ## See the following links for a community discussion and overview regarding the selections.
          ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989
          ## https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules

          ## Blacklisting prevents kernel modules from automatically starting.
          ## Disabling prohibits kernel modules from starting.

          ## Bluetooth:
          ## Disable Bluetooth to reduce attack surface due to extended history of security vulnerabilities.
          ##
          ## https://en.wikipedia.org/wiki/Bluetooth#History_of_security_concerns
          ##
          ## Now replaced by a privacy and security preserving default Bluetooth configuration for better usability.
          ## https://github.com/Kicksecure/security-misc/pull/145
          ##
          #install bluetooth /usr/bin/disabled-bluetooth-by-security-misc
          #install bluetooth_6lowpan  /usr/bin/disabled-bluetooth-by-security-misc
          #install bt3c_cs /usr/bin/disabled-bluetooth-by-security-misc
          #install btbcm /usr/bin/disabled-bluetooth-by-security-misc
          #install btintel /usr/bin/disabled-bluetooth-by-security-misc
          #install btmrvl /usr/bin/disabled-bluetooth-by-security-misc
          #install btmrvl_sdio /usr/bin/disabled-bluetooth-by-security-misc
          #install btmtk /usr/bin/disabled-bluetooth-by-security-misc
          #install btmtksdio /usr/bin/disabled-bluetooth-by-security-misc
          #install btmtkuart /usr/bin/disabled-bluetooth-by-security-misc
          #install btnxpuart /usr/bin/disabled-bluetooth-by-security-misc
          #install btqca /usr/bin/disabled-bluetooth-by-security-misc
          #install btrsi /usr/bin/disabled-bluetooth-by-security-misc
          #install btrtl /usr/bin/disabled-bluetooth-by-security-misc
          #install btsdio /usr/bin/disabled-bluetooth-by-security-misc
          #install btusb /usr/bin/disabled-bluetooth-by-security-misc
          #install virtio_bt /usr/bin/disabled-bluetooth-by-security-misc

          ## CPU Model-Specific Registers (MSRs):
          ## Disable CPU MSRs as they can be abused to write to arbitrary memory.
          ##
          ## https://security.stackexchange.com/questions/119712/methods-root-can-use-to-elevate-itself-to-kernel-mode
          ## https://github.com/Kicksecure/security-misc/issues/215
          ##
          install msr /usr/bin/disabled-miscellaneous-by-security-misc

          ## File Systems:
          ## Disable uncommon file systems to reduce attack surface.
          ## HFS/HFS+ are legacy Apple file systems that may be required depending on the EFI partition format.
          ##
          install cramfs /usr/bin/disabled-filesys-by-security-misc
          install freevxfs /usr/bin/disabled-filesys-by-security-misc
          install hfs /usr/bin/disabled-filesys-by-security-misc
          install hfsplus /usr/bin/disabled-filesys-by-security-misc
          install jffs2 /usr/bin/disabled-filesys-by-security-misc
          install jfs /usr/bin/disabled-filesys-by-security-misc
          install reiserfs /usr/bin/disabled-filesys-by-security-misc
          install udf /usr/bin/disabled-filesys-by-security-misc

          ## FireWire (IEEE 1394):
          ## Disable IEEE 1394 (FireWire/i.LINK/Lynx) modules to prevent some DMA attacks.
          ##
          ## https://en.wikipedia.org/wiki/IEEE_1394#Security_issues
          ##
          install dv1394 /usr/bin/disabled-firewire-by-security-misc
          install firewire-core /usr/bin/disabled-firewire-by-security-misc
          install firewire-ohci /usr/bin/disabled-firewire-by-security-misc
          install firewire-net /usr/bin/disabled-firewire-by-security-misc
          install firewire-sbp2 /usr/bin/disabled-firewire-by-security-misc
          install ohci1394 /usr/bin/disabled-firewire-by-security-misc
          install raw1394 /usr/bin/disabled-firewire-by-security-misc
          install sbp2 /usr/bin/disabled-firewire-by-security-misc
          install video1394 /usr/bin/disabled-firewire-by-security-misc

          ## Global Positioning Systems (GPS):
          ## Disable GPS-related modules like GNSS (Global Navigation Satellite System).
          ##
          install garmin_gps /usr/bin/disabled-gps-by-security-misc
          install gnss /usr/bin/disabled-gps-by-security-misc
          install gnss-mtk /usr/bin/disabled-gps-by-security-misc
          install gnss-serial /usr/bin/disabled-gps-by-security-misc
          install gnss-sirf /usr/bin/disabled-gps-by-security-misc
          install gnss-ubx /usr/bin/disabled-gps-by-security-misc
          install gnss-usb /usr/bin/disabled-gps-by-security-misc

          ## Intel Management Engine (ME):
          ## Partially disable the Intel ME interface with the OS.
          ## ME functionality has increasing become more intertwined with basic Intel system operation.
          ## Disabling may lead to breakages in places such as security, power management, display, and DRM.
          ##
          ## https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
          ## https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
          ## https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
          ## https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
          ## https://github.com/Kicksecure/security-misc/issues/239
          ##
          #install mei /usr/bin/disabled-intelme-by-security-misc
          #install mei-gsc /usr/bin/disabled-intelme-by-security-misc
          #install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
          #install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
          #install mei-me /usr/bin/disabled-intelme-by-security-misc
          #install mei_phy /usr/bin/disabled-intelme-by-security-misc
          #install mei_pxp /usr/bin/disabled-intelme-by-security-misc
          #install mei-txe /usr/bin/disabled-intelme-by-security-misc
          #install mei-vsc /usr/bin/disabled-intelme-by-security-misc
          #install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
          #install mei_wdt /usr/bin/disabled-intelme-by-security-misc
          #install microread_mei /usr/bin/disabled-intelme-by-security-misc

          ## Intel Platform Monitoring Technology Telemetry (PMT):
          ## Disable some functionality of the Intel PMT components.
          ##
          ## https://github.com/intel/Intel-PMT
          ##
          install pmt_class /usr/bin/disabled-intelpmt-by-security-misc
          install pmt_crashlog /usr/bin/disabled-intelpmt-by-security-misc
          install pmt_telemetry /usr/bin/disabled-intelpmt-by-security-misc

          ## Network File Systems:
          ## Disable uncommon network file systems to reduce attack surface.
          ##
          install gfs2 /usr/bin/disabled-netfilesys-by-security-misc
          install ksmbd /usr/bin/disabled-netfilesys-by-security-misc
          ##
          ## Common Internet File System (CIFS):
          ##
          install cifs /usr/bin/disabled-netfilesys-by-security-misc
          install cifs_arc4 /usr/bin/disabled-netfilesys-by-security-misc
          install cifs_md4 /usr/bin/disabled-netfilesys-by-security-misc
          ##
          ## Network File System (NFS):
          ##
          install nfs /usr/bin/disabled-netfilesys-by-security-misc
          install nfs_acl /usr/bin/disabled-netfilesys-by-security-misc
          install nfs_layout_nfsv41_files /usr/bin/disabled-netfilesys-by-security-misc
          install nfs_layout_flexfiles /usr/bin/disabled-netfilesys-by-security-misc
          install nfsd /usr/bin/disabled-netfilesys-by-security-misc
          install nfsv2 /usr/bin/disabled-netfilesys-by-security-misc
          install nfsv3 /usr/bin/disabled-netfilesys-by-security-misc
          install nfsv4 /usr/bin/disabled-netfilesys-by-security-misc

          ## Network Protocols:
          ## Disables rare and unneeded network protocols that are a common source of unknown vulnerabilities.
          ## Previously had blacklisted eepro100 and eth1394.
          ##
          ## https://tails.boum.org/blueprint/blacklist_modules/
          ## https://fedoraproject.org/wiki/Security_Features_Matrix#Blacklist_Rare_Protocols
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-rare-network.conf?h=ubuntu/disco
          ## https://github.com/Kicksecure/security-misc/pull/234#issuecomment-2230732015
          ##
          install af_802154 /usr/bin/disabled-network-by-security-misc
          install appletalk /usr/bin/disabled-network-by-security-misc
          install ax25 /usr/bin/disabled-network-by-security-misc
          #install brcm80211 /usr/bin/disabled-network-by-security-misc
          install decnet /usr/bin/disabled-network-by-security-misc
          install dccp /usr/bin/disabled-network-by-security-misc
          install econet /usr/bin/disabled-network-by-security-misc
          install eepro100 /usr/bin/disabled-network-by-security-misc
          install eth1394 /usr/bin/disabled-network-by-security-misc
          install ipx /usr/bin/disabled-network-by-security-misc
          install n-hdlc /usr/bin/disabled-network-by-security-misc
          install netrom /usr/bin/disabled-network-by-security-misc
          install p8022 /usr/bin/disabled-network-by-security-misc
          install p8023 /usr/bin/disabled-network-by-security-misc
          install psnap /usr/bin/disabled-network-by-security-misc
          install rose /usr/bin/disabled-network-by-security-misc
          install x25 /usr/bin/disabled-network-by-security-misc
          ##
          ## Asynchronous Transfer Mode (ATM):
          ##
          install atm /usr/bin/disabled-network-by-security-misc
          install ueagle-atm /usr/bin/disabled-network-by-security-misc
          install usbatm /usr/bin/disabled-network-by-security-misc
          install xusbatm /usr/bin/disabled-network-by-security-misc
          ##
          ## Controller Area Network (CAN) Protocol:
          ##
          install c_can /usr/bin/disabled-network-by-security-misc
          install c_can_pci /usr/bin/disabled-network-by-security-misc
          install c_can_platform /usr/bin/disabled-network-by-security-misc
          install can /usr/bin/disabled-network-by-security-misc
          install can-bcm /usr/bin/disabled-network-by-security-misc
          install can-dev /usr/bin/disabled-network-by-security-misc
          install can-gw /usr/bin/disabled-network-by-security-misc
          install can-isotp /usr/bin/disabled-network-by-security-misc
          install can-raw /usr/bin/disabled-network-by-security-misc
          install can-j1939 /usr/bin/disabled-network-by-security-misc
          install can327 /usr/bin/disabled-network-by-security-misc
          install ifi_canfd /usr/bin/disabled-network-by-security-misc
          install janz-ican3 /usr/bin/disabled-network-by-security-misc
          install m_can /usr/bin/disabled-network-by-security-misc
          install m_can_pci /usr/bin/disabled-network-by-security-misc
          install m_can_platform /usr/bin/disabled-network-by-security-misc
          install phy-can-transceiver /usr/bin/disabled-network-by-security-misc
          install slcan /usr/bin/disabled-network-by-security-misc
          install ucan /usr/bin/disabled-network-by-security-misc
          install vxcan /usr/bin/disabled-network-by-security-misc
          install vcan /usr/bin/disabled-network-by-security-misc
          ##
          ## Transparent Inter Process Communication (TIPC):
          ##
          install tipc /usr/bin/disabled-network-by-security-misc
          install tipc_diag /usr/bin/disabled-network-by-security-misc
          ##
          ## Reliable Datagram Sockets (RDS):
          ##
          install rds /usr/bin/disabled-network-by-security-misc
          install rds_rdma /usr/bin/disabled-network-by-security-misc
          install rds_tcp /usr/bin/disabled-network-by-security-misc
          ##
          ## Stream Control Transmission Protocol (SCTP):
          ##
          install sctp /usr/bin/disabled-network-by-security-misc
          install sctp_diag /usr/bin/disabled-network-by-security-misc

          ## Miscellaneous:
          ##
          ## Amateur Radios:
          ##
          install hamradio /usr/bin/disabled-miscellaneous-by-security-misc
          ##
          ## Floppy Disks:
          ##
          install floppy /usr/bin/disabled-miscellaneous-by-security-misc
          ##
          ## Vivid:
          ## Disables the vivid kernel module since it has been the cause of multiple vulnerabilities.
          ##
          ## https://forums.whonix.org/t/kernel-recompilation-for-better-hardening/7598/233
          ## https://www.openwall.com/lists/oss-security/2019/11/02/1
          ## https://github.com/a13xp0p0v/kconfig-hardened-check/commit/981bd163fa19fccbc5ce5d4182e639d67e484475
          ##
          install vivid /usr/bin/disabled-miscellaneous-by-security-misc

          ## Thunderbolt:
          ## Disables Thunderbolt modules to prevent some DMA attacks.
          ##
          ## https://en.wikipedia.org/wiki/Thunderbolt_(interface)#Security_vulnerabilities
          ##
          install intel-wmi-thunderbolt /usr/bin/disabled-thunderbolt-by-security-misc
          install thunderbolt /usr/bin/disabled-thunderbolt-by-security-misc
          install thunderbolt_net /usr/bin/disabled-thunderbolt-by-security-misc

          ## USB Video Device Class:
          ## Disables the USB-based video streaming driver for devices like some webcams and digital camcorders.
          ##
          #install uvcvideo /usr/bin/disabled-miscellaneous-by-security-misc



          ### Kicksecure/security-misc
          ### etc/modprobe.d/30_security-misc_conntrack.conf - Last updated July 29, 2024

          ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          ## Conntrack:
          ## Disable Netfilter's automatic connection tracking helper assignment.
          ## Increases kernel attack surface by enabling superfluous functionality such as IRC parsing in the kernel.
          ##
          ## https://conntrack-tools.netfilter.org/manual.html
          ## https://forums.whonix.org/t/disable-conntrack-helper/18917
          ##
          options nf_conntrack nf_conntrack_helper=0



          ### Kicksecure/security-misc
          ### etc/modprobe.d/30_security-misc_blacklist.conf - Last updated July 29, 2024

          ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          ## See the following links for a community discussion and overview regarding the selections.
          ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989
          ## https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules

          ## Blacklisting prevents kernel modules from automatically starting.
          ## Disabling prohibits kernel modules from starting.

          ## CD-ROM/DVD:
          ## Blacklist CD-ROM and DVD modules.
          ## Do not disable by default for potential future ISO plans.
          ##
          ## https://nvd.nist.gov/vuln/detail/CVE-2018-11506
          ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989/31
          ##
          blacklist cdrom
          blacklist sr_mod
          ##
          #install cdrom /usr/bin/disabled-cdrom-by-security-misc
          #install sr_mod /usr/bin/disabled-cdrom-by-security-misc

          ## Framebuffer Drivers:
          ##
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-framebuffer.conf?h=ubuntu/disco
          ##
          blacklist aty128fb
          blacklist atyfb
          blacklist cirrusfb
          blacklist cyber2000fb
          blacklist cyblafb
          blacklist gx1fb
          blacklist hgafb
          blacklist i810fb
          blacklist intelfb
          blacklist kyrofb
          blacklist lxfb
          blacklist matroxfb_bases
          blacklist neofb
          blacklist nvidiafb
          blacklist pm2fb
          blacklist radeonfb
          blacklist rivafb
          blacklist s1d13xxxfb
          blacklist savagefb
          blacklist sisfb
          blacklist sstfb
          blacklist tdfxfb
          blacklist tridentfb
          blacklist vesafb
          blacklist vfb
          blacklist viafb
          blacklist vt8623fb
          blacklist udlfb

          ## Miscellaneous:
          ##
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-ath_pci.conf?h=ubuntu/disco
          ##
          blacklist ath_pci
          blacklist amd76x_edac
          blacklist asus_acpi
          blacklist bcm43xx
          blacklist evbug
          blacklist de4x5
          blacklist pcspkr
          blacklist prism54
          blacklist snd_aw2
          blacklist snd_intel8x0m
          blacklist snd_pcsp
          blacklist usbkbd
          blacklist usbmouse



          ### secureblue/secureblue
          ### files/system/usr/etc/modprobe.d/blacklist.conf - Last updated July 29, 2024

          # unused filesystems
          install squashfs /bin/false
          install kafs /bin/false
          install orangefs /bin/false
          install 9p /bin/false
          install adfs /bin/false
          install affs /bin/false
          install afs /bin/false
          install befs /bin/false
          install ceph /bin/false
          install coda /bin/false
          install ecryptfs /bin/false
          install erofs /bin/false
          install minix /bin/false
          install netfs /bin/false
          install nilfs2 /bin/false
          install ocfs2 /bin/false
          install romfs /bin/false
          install ubifs /bin/false
          install zonefs /bin/false
        '';
      };
    };
  };

  ### Filesystem hardening

  fileSystems = {
    # noexec on /home can be very inconvenient for desktops. See overrides.
    "/home" = {
      device = "/home";
      options = [ ("bind") ("nosuid") ("noexec") ("nodev") ];
    };

    # Some applications may need to be executable in /tmp. See overrides.
    "/tmp" = { 
      device = "/tmp";
      options = [ ("bind") ("nosuid") ("noexec") ("nodev") ];
    };

    # noexec on /var may cause breakage. See overrides.
    "/var" = { 
      device = "/var";
      options = [ ("bind") ("nosuid") ("noexec") ("nodev") ];
    };

    "/boot" = { options = [ ("nosuid") ("noexec") ("nodev") ]; };
  };

  boot.specialFileSystems = {
    # Use NixOS default options for /dev/shm but add noexec.
    "/dev/shm" = { 
      fsType = "tmpfs"; 
      options = [ "nosuid" "nodev" "noexec" "strictatime" "mode=1777" "size=${config.boot.devShmSize}" ]; 
    };

    # Hide processes from other users except root, may cause breakage.
    # See overrides, in desktop section.
    "/proc" = {
      fsType = "proc";
      device = "proc";
      options = [ "nosuid" "nodev" "noexec" "hidepid=2" "gid=proc" ];
    };
  };

  # Add "proc" group to whitelist /proc access and allow systemd-logind to view
  # /proc in order to unbreak it.
  users.groups.proc = {};
  systemd.services.systemd-logind.serviceConfig = { SupplementaryGroups = [ "proc" ]; };

  # Enables firewall. You may need to tweak your firewall rules depending on
  # your usecase. On a desktop, this shouldn't cause problems. 
  networking = { 
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      enable = true;
    };
    networkmanager = {
      ethernet = { macAddress = "random"; };
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
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
        ({
          domain = "*";
          item = "core";
          type = "hard";
          value = "0";
        })
      ];
      services = {
        # Increase hashing rounds for /etc/shadow; this doesn't automatically
        # rehash your passwords, you'll need to set passwords for your accounts
        # again for this to work.
        passwd = { 
          text = ''
            password required pam_unix.so sha512 shadow nullok rounds=65536
          '';
        };
        # Enable PAM support for securetty, to prevent root login.
        # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
        login = {
          text = pkgs.lib.mkDefault( pkgs.lib.mkBefore ''
            # Enable securetty support.
            auth       requisite  pam_nologin.so
            auth       requisite  pam_securetty.so
          '');
        };

        su = { requireWheel = true; };
        su-l = { requireWheel = true; };
        system-login = { failDelay = { delay = "4000000"; }; };
      };
    };
  };
  services = {
    # Disallow root login over SSH. Doesn't matter on systems without SSH.
    openssh = { settings = { PermitRootLogin = "no"; }; };
     
    # DNS connections will fail if not using a DNS server supporting DNSSEC.
    resolved = { dnssec = "true"; }; 

    # Prevent BadUSB attacks, but requires whitelisting of USB devices. 
    usbguard = {   
      enable = true;
    };
  };

  # Get extra entropy since we disabled hardware entropy sources
  # Read more about why at the following URLs:
  # https://github.com/smuellerDD/jitterentropy-rngd/issues/27
  # https://blogs.oracle.com/linux/post/rngd1
  services.jitterentropy-rngd = { enable = true; };
  boot.kernelModules = [ ("jitterentropy_rng") ];

  # Disable systemd coredump to reduce available information to an attacker.
  systemd.coredump.enable = false;

  systemd.tmpfiles.settings = {
    # Restrict permissions of /home/$USER so that only the owner of the
    # directory can access it (the user). systemd-tmpfiles also has the benefit
    # of recursively setting permissions too, with the "Z" option as seen below.
    "restricthome" = {
      "/home/*" = {
        Z = {
          mode = "0700";
        };
      };
    };

    # Make all files in /etc/nixos owned by root, and only readable by root.
    # /etc/nixos is not owned by root by default, and configuration files can
    # on occasion end up also not owned by root. This can be hazardous as files
    # that are included in the rebuild may be editable by unprivileged users,
    # so this mitigates that.
    "restrictetcnixos" = {
      "/etc/nixos/*" = {
        Z = {
          mode = "0000";
          user = "root";
          group = "root";
        };
      };
    };
  };
  
  # zram allows swapping to RAM by compressing memory. This reduces the chance
  # that sensitive data is written to disk, and eliminates it if zram is used
  # to completely replace swap to disk. Generally *improves* storage lifespan
  # and performance, there usually isn't a need to disable this.
  zramSwap = { enable = true; };

  # Limit access to nix to users with the "wheel" group. ("sudoers")
  nix.settings.allowed-users = mkForce [ ("@wheel") ];
}))
