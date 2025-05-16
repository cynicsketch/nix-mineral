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



# This is the overrides file for nix-mineral, containing a non-comprehensive
# list of options that one may wish to override for any number of reasons.
# 
# The goal is primarily to provide a premade template for users to make
# nix-mineral work with any system and use case.

({ config, lib, pkgs, ... }:

(with lib; {

## Compatibility
# Options to ensure compatibility with certain usecases and hardware, at the
# expense of overall security.

  # Set boot parameter "module.sig_enforce=0" to allow loading unsigned kernel
  # modules, which may include certain drivers. Lockdown must also be disabled,
  # see option below this one.
  # nm-overrides.compatibility.allow-unsigned-modules.enable = true;

  # Disable Linux Kernel Lockdown to *permit* loading unsigned kernel modules
  # and hibernation.
  # nm-overrides.compatibility.no-lockdown.enable = true;

  # Enable binfmt_misc. This is required for Roseta to function.
  # nm-overrides.compatibility.binfmt-misc.enable = true;

  # Reenable the busmaster bit at boot. This may help with low resource systems
  # that are prevented from booting by the defaults of nix-mineral.
  # nm-overrides.compatibility.busmaster-bit.enable = true;

  # Reenable io_uring, which is the cause of many vulnerabilities. This may
  # be desired for specific environments concerning Proxmox.
  # nm-overrides.compatibility.io-uring.enable = true;

  # Enable ip forwarding. Useful for certain VM networking and is required if
  # the system is meant to function as a router.
  # nm-overrides.compatibility.ip-forward.enable = true;



## Desktop
# Options that are useful to desktop experience and general convenience. Some
# of these may also be to specific server environments, too. Most of these
# options reduce security to a certain degree.

  # Reenable multilib, may be useful to playing certain games.
  # nm-overrides.desktop.allow-multilib.enable = true;

  # Reenable unprivileged userns. Although userns is the target of many
  # exploits, it also used in the Chromium sandbox, unprivileged containers,
  # and bubblewrap among many other applications.
  # nm-overrides.desktop.allow-unprivileged-userns.enable = true;

  # Enable doas-sudo wrapper, useful for scripts that use "sudo." Installs
  # nano for rnano as a "safe" method of editing text as root. 
  # Use this when replacing sudo with doas, see "Software Choice."
  # sudo = doas
  # doasedit/sudoedit = doas rnano
  # nm-overrides.desktop.doas-sudo-wrapper.enable = true;

  # Allow executing binaries in /home. Highly relevant for games and other
  # programs executing in the /home folder.
  # nm-overrides.desktop.home-exec.enable = true;

  # Allow executing binaries in /tmp. Certain applications may need to execute
  # in /tmp, Java being one example.
  # nm-overrides.desktop.tmp-exec.enable = true;

  # Allow executing binaries in /var/lib. LXC, and system-wide Flatpaks are
  # among some examples of applications that requiring executing in /var/lib.
  # nm-overrides.desktop.var-lib-exec.enable = true;

  # Allow all users to use nix, rather than just users of the "wheel" group.
  # May be useful for allowing a non-wheel user to, for example, use devshell.
  # nm-overrides.desktop.nix-allow-all-users.enable = true;

  # Automatically allow all connected devices at boot in USBGuard. Note that
  # for laptop users, inbuilt speakers and bluetooth cards may be disabled
  # by USBGuard by default, so whitelisting them manually or enabling this
  # option may solve that.
  # nm-overrides.desktop.usbguard-allow-at-boot.enable = true;

  # Enable USBGuard dbus daemon and add polkit rules to integrate USBGuard with
  # GNOME Shell. If you use GNOME, this means that USBGuard automatically
  # allows all newly connected devices while unlocked, and blacklists all
  # newly connected devices while locked. This is obviously very convenient,
  # and is similar behavior to handling USB as ChromeOS and GrapheneOS.
  # nm-overrides.usbguard-gnome-integration.enable = true;

  # Completely disable USBGuard to avoid hassle with handling USB devices at
  # all.
  # nm-overrides.desktop.usbguard-disable.enable = true;

  # Rather than disable ptrace entirely, restrict ptrace so that parent
  # processes can ptrace descendants. May allow certain Linux game anticheats
  # to function.
  # nm-overrides.desktop.yama-relaxed.enable = true;

  # Allow processes that can ptrace a process to read its process information.
  # Requires ptrace to even be allowed in the first place, see above option.
  # Note: While nix-mineral has made provisions to unbreak systemd, it is
  # not supported by upstream, and breakage may still occur:
  # https://github.com/systemd/systemd/issues/12955
  # nm-overrides.desktop.hideproc-relaxed.enable = true;



## Performance
# Options to revert some performance taxing tweaks by nix-mineral, at the cost
# of security. In general, it's recommended not to use these unless your system
# is otherwise unusable without tweaking these.

  # Allow symmetric multithreading and just use default CPU mitigations, to
  # potentially improve performance.
  # nm-overrides.performance.allow-smt.enable = true;

  # Disable all CPU mitigations. Do not use with the above option. May improve
  # performance further, but is even more dangerous!
  # nm-overrides.performance.no-mitigations.enable = true;

  # Enable bypassing the IOMMU for direct memory access. Could increase I/O
  # performance on ARM64 systems, with risk. See URL: https://wiki.ubuntu.com/ARM64/performance
  # nm-overrides.performance.iommu-passthrough.enable = true;

  # Page table isolation mitigates some KASLR bypasses and the Meltdown CPU
  # vulnerability. It may also tax performance, so this option disables it.
  # nm-overrides.perforamcne.no-pti.enable = true;



## Security
# Other security related options that were not enabled by default for one
# reason or another.

  # Lock the root account. Requires another method of privilege escalation, i.e
  # sudo or doas, and declarative accounts to work properly.
  # nm-overrides.security.lock-root.enable = true;

  # Reduce swappiness to bare minimum. May reduce risk of writing sensitive
  # information to disk, but hampers zram performance. Also useless if you do
  # not even use a swap file/partition, i.e zram only setup.
  # nm-overrides.security.minimum-swappiness.enable = true;

  # Enable SAK (Secure Attention Key). SAK prevents keylogging, if used
  # correctly. See URL: https://madaidans-insecurities.github.io/guides/linux-hardening.html#accessing-root-securely
  # nm-overrides.security.sysrq-sak.enable = true;

  # Privacy/security split.
  # This option disables TCP timestamps. By default, nix-mineral enables
  # tcp-timestamps. Disabling prevents leaking system time, enabling protects
  # against wrapped sequence numbers and improves performance.
  #
  # Read more about the issue here:
  # URL: (In favor of disabling): https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
  # URL: (In favor of enabling): https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
  # nm-overrides.security.tcp-timestamp-disable.enable = true;

  # Disable loading kernel modules (except those loaded at boot via kernel
  # commandline)
  # Very likely to cause breakage unless you can compile a list of every module
  # you need and add that to your boot parameters manually.
  # nm-overrides.security.disable-modules.enable = true;

  # Disable TCP window scaling. May help mitigate TCP reset DoS attacks, but
  # may also harm network performance when at high latencies.
  # nm-overrides.security.disable-tcp-window-scaling.enable = true;

  # Disable bluetooth entirely. nix-mineral borrows a privacy preserving
  # bluetooth configuration file by default, but if you never use bluetooth
  # at all, this can reduce attack surface further.
  # nm-overrides.security.disable-bluetooth.enable = true;

  # Disable Intel ME related kernel modules. This is to avoid putting trust in
  # the highly privilege ME system, but there are potentially other
  # consequences.
  #
  # If you use an AMD system, you can enable this without negative consequence
  # and reduce attack surface.
  #
  # Intel users should read more about the issue at the below links:
  # https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
  # https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
  # https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
  # https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
  # https://github.com/Kicksecure/security-misc/issues/239
  #
  # nm-overrides.security.disable-intelme-kmodules.enable = true;

  # DO NOT USE THIS OPTION ON ANY PRODUCTION SYSTEM! FOR TESTING PURPOSES ONLY!
  # Use hardened-malloc as default memory allocator for all processes.
  # nm-overrides.security.hardened-malloc.enable = true;



## Software Choice
# Options to add (or remove) opinionated software replacements by nix-mineral.

  # Replace sudo with doas. doas has a lower attack surface, but is less
  # audited.
  # nm-overrides.software-choice.doas-no-sudo.enable = true;

  # Replace systemd-timesyncd with chrony, for NTS support and its seccomp
  # filter.
  # nm-overrides.software-choice.secure-chrony.enable = true;

  # Use Linux Kernel with hardened patchset. Concurs a multitude of security
  # benefits, but prevents hibernation.*
  #
  # (No longer recommended as of July 25, 2024. The patchset being behind by
  # about a week or so is one thing, but the package as included in nixpkgs is
  # way too infrequently updated, being several weeks or even months behind.
  # Therefore, it is recommended to choose an LTS kernel like 5.15, 6.1, or 6.6
  # in your own system configuration.*)
  #
  # nm-overrides.software-choice.hardened-kernel.enable = true;

  # Dont use the nix-mineral default firewall, if you wish to use alternate
  # applications for the same purpose.
  # nm-overrides.software-choice.no-firewall.enable = true;

}))
