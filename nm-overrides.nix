# This is the overrides file for nix-mineral, containing a non-comprehensive
# list of options that one may wish to override for any number of reasons.
# 
# The goal is primarily to provide a premade template for users to make
# nix-mineral work with any system and use case, however,

({ config, lib, pkgs, ... }:

(with lib; {

  ## Common desktop overrides/convenience

  # Remove noexec if you must run executables in /home.
  # fileSystems."/home" = mkForce {
  #   device = "/home";
  #   options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
  # };

  # Programs may need to be executed in /tmp, consult respective documentation
  # for any malfunctioning apps. Particularly, Java can require an exec /tmp
  # to function.
  # fileSystems."/tmp" = mkForce {
  #   device = "/tmp";
  #   options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
  # };
    
  # Enables programs to execute in /var/lib, which unbreaks some programs
  # such as system-wide Flatpaks and LXC.
  # fileSystems."/var/lib" = mkForce { 
  #   device = "/var/lib";
  #   options = [ ("bind") ("nosuid") ("exec") ("nodev") ];
  # };
   
  # Automatically allow all USB devices connected at boot time in USBGuard.
  # Leniency may provoke insecurity.
  # services.usbguard.presentDevicePolicy = mkForce "allow"; 

  # These polkit rules allow USBGuard integration for GNOME. This means that
  # while using GNOME, USBGuard will automatically blacklist all USB devices
  # while the system is locked, but automatically allow all USB devices when
  # unlocked, similarly to ChromeOS and GrapheneOS.
  # security.polkit = { 
  #   extraConfig = ''
  #     polkit.addRule(function(action, subject) {
  #         if ((action.id == "org.usbguard.Policy1.listRules" ||
  #              action.id == "org.usbguard.Policy1.appendRule" ||
  #              action.id == "org.usbguard.Policy1.removeRule" ||
  #              action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
  #              action.id == "org.usbguard.Devices1.listDevices" ||
  #              action.id == "org.usbguard1.getParameter" ||
  #              action.id == "org.usbguard1.setParameter") &&
  #              subject.active == true && subject.local == true &&
  #              subject.isInGroup("wheel")) {
  #                 return polkit.Result.YES;
  #         }
  #     });
  #   '';
  # };
  
  # Disable USBGuard, so that one does not have to manually whitelist USB
  # devices in the absence of GNOME Shell integration or otherwise. May create
  # vulnerability to BadUSB attacks in the absence of other solutions.
  # services.usbguard.enable = mkForce false;
  
  # Don't limit access to nix to users with the "wheel" group. ("sudoers") May
  # be desired if using devshell as a non-wheel user.
  # nix.settings.allowed-users = mkForce [ ("*") ];

  # Unprivileged userns, though a significant security risk, is used
  # in many unprivileged container software, Flatpaks, etc, and so it
  # should be reenabled on most desktops.
  # boot.kernel.sysctl."kernel.unprivileged_userns_clone" = mkForce "1";
        
  # Relax Yama ptrace restrictions to accomodate for certain Linux game
  # anticheats.
  # boot.kernel.sysctl."kernel.yama.ptrace_scope" = mkForce "1";

  boot.kernelParams = mkOverride 100 [
  # Allow use of unsigned kernel modules, for driver support.
  # ("module.sig_enforce=0")
      
  # Disable Linux kernel lockdown. Harms security, but allows use of unsigned
  # kernel modules (must be used with above option) and allows hibernation
  # (must also not be using hardened kernel patchset).
  # ("lockdown=")

  # Reenable symmetric multithreading. May improve performance, but also may
  # enable certain CPU vulnerabilities. Can also be set to "off" for more
  # performance but this is an even greater security risk and only ever
  # suggested if the system is completely unusable with mitigations.
  # ("mitigations=auto")

  # Disable page table isolation. May improve performance, but may also enable
  # certain CPU vulnerabilities.
  # ("pti=off")

  # Enable multilib. This may increase attack surface, but allows 32 bit apps
  # to run on a 64 bit system, which may be useful in regards to certain games.
  # ("ia32_emulation=1")

  # May prevent some systems from booting.
  # ("efi=no_disable_early_pci_dma")

  # Allows DMA to bypass the IOMMU, for certain uses requiring DMA. Hurts
  # security. 
  # ("iommu.passthrough=1") 
  ];
   
  # doas-sudo wrapper for convenience. rnano is restricted in functionality,
  # which provides similar security benefits as sudoedit, although a bit less
  # free in editor choice.
  # environment.systemPackages = (with pkgs; [ 
  #   ((pkgs.writeScriptBin "sudo" ''exec doas "$@"''))
  #   ((pkgs.writeScriptBin "sudoedit" ''exec doas rnano "$@"''))
  #   ((pkgs.writeScriptBin "doasedit" ''exec doas rnano "$@"''))
  #   nano
  # ]);



  ### Potentially controversial default software

  # Adjust firewall ports as needed. Not usually necessary on a desktop.
  # networking.firewall.allowedTCPPorts = mkForce [ ];
  # networking.firewall.allowedUDPPorts = mkForce [ ];
  
  # Disable firewall as provided by Nix. Not usually recommended, but some
  # users may have opinions on firewall software choice.
  # networking.firewall.enable = mkForce true;

  # doas is recommended due to fulfilling the most common usecases for sudo
  # while having less attack surface. It is less audited, however, and some
  # users may wish to use sudo instead. The following options disable doas
  # and reenable sudo.
  # security.sudo.enable = mkForce true; 
  # security.doas.enable = mkForce false;

  # Although chrony is recommended due to its NTS support and is not known to
  # generally cause issue, some users may prefer systemd-timesyncd or another
  # NTP service regardless. This disables chrony and reenables timesyncd. 
  # services.timesyncd.enable = mkForce true;     
  # services.chrony.enable = mkForce false;
  
  # Use vanilla Linux kernel (i.e, without hardened patchset) to be able to
  # use hibernation and potentially improve performance. Hibernation only
  # matters on battery operated systems.
  # boot.kernelPackages = mkForce (pkgs).linuxPackages;



  ## Miscellaneous relevant overrides

  # Enable SAK (Secure Attention Key). SAK prevents keylogging, if used
  # correctly. See URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html#accessing-root-securely
  # boot.kernel.sysctl."kernel.sysrq" = mkForce "4";

  # Decrease swappiness if swapping to disk, to reduce risk of writing
  # sensitive info to non-volatile storage. Negates any performance gains from
  # using zram. Pointless if not using swap to disk (i.e, zram only).
  # boot.kernel.sysctl."vm.swappiness" = mkForce "1";

  # Reenable binfmt to make Roseta work again. Worsens security.
  # boot.kernel.sysctl."fs.binfmt_misc.status" = mkForce "1";

  # Reenable io_uring for some usecases in Proxmox. Worsens security
  # significantly.
  # boot.kernel.sysctl."kernel.io_uring_disabled" = mkForce "0";

  # Enable ip forwarding if you need it, e.g VM networking.
  # boot.kernel.sysctl."net.ipv4.ip_forward" = mkForce "1";
  # boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = mkForce "1";

  # Privacy/security split.
  # Set to 1 to protect against wrapped sequence numbers and improve
  # overall network performance.
  #
  # Set to 0 to avoid leaking system time.
  #
  # Default value in nix-mineral is "1"
  #
  # Read more about the issue here:
  # URL: (In favor of disabling): https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
  # URL: (In favor of enabling): https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
  # boot.kernel.sysctl."net.ipv4.tcp_timestamps" = mkForce "0";



  ## Excluded security options

  # Use hardened memory allocator for all software run. This is not enabled by
  # default due to its potential to completely break a system. It is included
  # here ONLY for testing purposes! DO NOT USE ON ANY PRODUCTION SYSTEM!
  # environment.memoryAllocator = { provider = "graphene-hardened"; };

  # Lock root user.
  # users = { users = { root = { hashedPassword = "!"; }; }; };

}))
