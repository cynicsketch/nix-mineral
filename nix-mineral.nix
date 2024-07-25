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
# 16 (Not needed with MAC spoofing)
# 19 (Advice)
# 20 (Not relevant)
# 21.7 (Advice, not in threat model)
# 22 (Advice)

# Sections from madaidan's guide requiring manual user intervention:
# 2.4 (Significant breakage)
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
# linux_hardened patched kernel which can reduce overall kernel attack surface.
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

      # Borrow Kicksecure bluetooth configuration for better bluetooth privacy
      # and security. Disables bluetooth automatically when not connected to
      # any device.
      "bluetooth/main.conf" = mkForce {
        text = ''
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
      "modprobe.d/nixos.conf" = {
        text = ''
          ## Copyright (C) 2012 - 2023 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
          ## See the file COPYING for copying conditions.

          ## See the following links for a community discussion and overview regarding the selections
          ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989
          ## https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules

          ## Disable automatic conntrack helper assignment
          ## https://phabricator.whonix.org/T486
          options nf_conntrack nf_conntrack_helper=0

          ## Disable bluetooth to reduce attack surface due to extended history of security vulnerabilities
          ## https://en.wikipedia.org/wiki/Bluetooth#History_of_security_concerns
          #
          ## Now replaced by a privacy and security preserving default bluetooth configuration for better usability
          #
          # install bluetooth /bin/disabled-bluetooth-by-security-misc
          # install btusb /bin/disabled-bluetooth-by-security-misc

          ## Disable thunderbolt and firewire modules to prevent some DMA attacks
          install thunderbolt /bin/disabled-thunderbolt-by-security-misc
          install firewire-core /bin/disabled-firewire-by-security-misc
          install firewire_core /bin/disabled-firewire-by-security-misc
          install firewire-ohci /bin/disabled-firewire-by-security-misc
          install firewire_ohci /bin/disabled-firewire-by-security-misc
          install firewire_sbp2 /bin/disabled-firewire-by-security-misc
          install firewire-sbp2 /bin/disabled-firewire-by-security-misc
          install ohci1394 /bin/disabled-firewire-by-security-misc
          install sbp2 /bin/disabled-firewire-by-security-misc
          install dv1394 /bin/disabled-firewire-by-security-misc
          install raw1394 /bin/disabled-firewire-by-security-misc
          install video1394 /bin/disabled-firewire-by-security-misc

          ## Disable CPU MSRs as they can be abused to write to arbitrary memory.
          ## https://security.stackexchange.com/questions/119712/methods-root-can-use-to-elevate-itself-to-kernel-mode
          install msr /bin/disabled-msr-by-security-misc

          ## Disables unneeded network protocols that will likely not be used as these may have unknown vulnerabilties.
          ## Credit to Tails (https://tails.boum.org/blueprint/blacklist_modules/) for some of these.
          ## > Debian ships a long list of modules for wide support of devices, filesystems, protocols. Some of these modules have a pretty bad security track record, and some of those are simply not used by most of our users.
          ## > Other distributions like Ubuntu[1] and Fedora[2] already ship a blacklist for various network protocols which aren't much in use by users and have a poor security track record.
          install dccp /bin/disabled-network-by-security-misc
          install sctp /bin/disabled-network-by-security-misc
          install rds /bin/disabled-network-by-security-misc
          install tipc /bin/disabled-network-by-security-misc
          install n-hdlc /bin/disabled-network-by-security-misc
          install ax25 /bin/disabled-network-by-security-misc
          install netrom /bin/disabled-network-by-security-misc
          install x25 /bin/disabled-network-by-security-misc
          install rose /bin/disabled-network-by-security-misc
          install decnet /bin/disabled-network-by-security-misc
          install econet /bin/disabled-network-by-security-misc
          install af_802154 /bin/disabled-network-by-security-misc
          install ipx /bin/disabled-network-by-security-misc
          install appletalk /bin/disabled-network-by-security-misc
          install psnap /bin/disabled-network-by-security-misc
          install p8023 /bin/disabled-network-by-security-misc
          install p8022 /bin/disabled-network-by-security-misc
          install can /bin/disabled-network-by-security-misc
          install atm /bin/disabled-network-by-security-misc

          ## Disable uncommon file systems to reduce attack surface
          ## HFS and HFS+ are legacy Apple filesystems that may be required depending on the EFI parition format
          install cramfs /bin/disabled-filesys-by-security-misc
          install freevxfs /bin/disabled-filesys-by-security-misc
          install jffs2 /bin/disabled-filesys-by-security-misc
          install hfs /bin/disabled-filesys-by-security-misc
          install hfsplus /bin/disabled-filesys-by-security-misc
          install udf /bin/disabled-filesys-by-security-misc

          ## Disable uncommon network file systems to reduce attack surface
          install cifs /bin/disabled-netfilesys-by-security-misc
          install nfs /bin/disabled-netfilesys-by-security-misc
          install nfsv3 /bin/disabled-netfilesys-by-security-misc
          install nfsv4 /bin/disabled-netfilesys-by-security-misc
          install ksmbd /bin/disabled-netfilesys-by-security-misc
          install gfs2 /bin/disabled-netfilesys-by-security-misc

          ## Disables the vivid kernel module as it's only required for testing and has been the cause of multiple vulnerabilities
          ## https://forums.whonix.org/t/kernel-recompilation-for-better-hardening/7598/233
          ## https://www.openwall.com/lists/oss-security/2019/11/02/1
          ## https://github.com/a13xp0p0v/kconfig-hardened-check/commit/981bd163fa19fccbc5ce5d4182e639d67e484475
          install vivid /bin/disabled-vivid-by-security-misc

          ## Disable Intel Management Engine (ME) interface with the OS
          ## https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
          install mei /bin/disabled-intelme-by-security-misc
          install mei-me /bin/disabled-intelme-by-security-misc

          ## Blacklist automatic loading of the Atheros 5K RF MACs madwifi driver
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-ath_pci.conf?h=ubuntu/disco
          blacklist ath_pci

          ## Blacklist automatic loading of miscellaneous modules
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
          blacklist ath_pci
          blacklist amd76x_edac
          blacklist asus_acpi
          blacklist bcm43xx
          blacklist eepro100
          blacklist eth1394
          blacklist evbug
          blacklist de4x5
          blacklist garmin_gps
          blacklist pcspkr
          blacklist prism54
          blacklist snd_aw2
          blacklist snd_intel8x0m
          blacklist snd_pcsp
          blacklist usbkbd
          blacklist usbmouse

          ## Blacklist automatic loading of framebuffer drivers
          ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-framebuffer.conf?h=ubuntu/disco
          blacklist aty128fb
          blacklist atyfb
          blacklist radeonfb
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

          ## Disable CD-ROM devices
          ## https://nvd.nist.gov/vuln/detail/CVE-2018-11506
          ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989/31
          #install cdrom /bin/disabled-cdrom-by-security-misc
          #install sr_mod /bin/disabled-cdrom-by-security-misc
          blacklist cdrom
          blacklist sr_mod



          ## Following blacklisted modules were pulled from secureblue

          # firewire and thunderbolt
          install firewire-net /bin/false

          # unused filesystems
          install squashfs /bin/false
          install reiserfs /bin/false
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
          install jfs /bin/false
          install minix /bin/false
          install netfs /bin/false
          install nilfs2 /bin/false
          install ocfs2 /bin/false
          install romfs /bin/false
          install ubifs /bin/false
          install udf /bin/false
          install zonefs /bin/false

          # disable GNSS
          install gnss /bin/false
          install gnss-mtk /bin/false
          install gnss-serial /bin/false
          install gnss-sirf /bin/false
          install gnss-usb /bin/false
          install gnss-ubx /bin/false
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
    "/dev/shm" = {
      device = "/dev/shm";
      options = [ ("bind") ("nosuid") ("noexec") ("nodev") ];
    };
  };

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

        su = { requireWheel = true; };
        su-l = { requireWheel = true; };
        system-login = { failDelay = { delay = "4000000"; }; };
      };
    };
  };
  services = {
    # Disallow root login over SSH. Doesn't matter on systems without SSH.
    openssh = { settings = { PermitRootLogin = "no"; }; };
    
    # Haveged adds entropy; it's not useless, unlike what the Arch wiki says.
    # The haveged *inspired* implementation in mainline Linux is different,
    # haveged can still provide additional entropy.
    haveged = { enable = true; };
     
    # DNS connections will fail if not using a DNS server supporting DNSSEC.
    resolved = { dnssec = "true"; }; 

    # Prevent BadUSB attacks, but requires whitelisting of USB devices. 
    usbguard = {   
      enable = true;
    };
  };

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
          mode = "0600";
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
