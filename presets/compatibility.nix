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

{
  config,
  l,
  mkPreset,
  ...
}:

{
  nix-mineral = {
    settings = {
      kernel = {
        # Enabling this option causes a hanging issue on linux kernel 6.13
        # so we only enable it for 6.14 and later
        amd-iommu-force-isolation = mkPreset (
          l.versionAtLeast (l.getVersion config.boot.kernelPackages.kernel) "6.14"
        );

        # if false, breaks Roseta, among other applications.
        binfmt-misc = mkPreset true;

        # if false, may prevent low resource systems from booting.
        busmaster-bit = mkPreset true;

        # Enable loading of unsigned kernel modules and enable hibernation.
        lockdown = mkPreset false;
        only-signed-modules = mkPreset false;

        # Don't crash the system if faulty drivers produce kernel oopses
        oops-panic = mkPreset false;
      };

      misc = {
        # Don't restrict nix to wheel, use default settings
        nix-wheel = mkPreset false;
      };

      system = {
        # allow 32-bit libraries and applications to run.
        multilib = mkPreset true;

        # allow certain legacy applications to map into lower address spaces
        # if needed
        lower-address-mmap = mkPreset true;

        # allow applications to ptrace their child processes, in the case of
        # certain software especially video game anticheats
        yama = "restricted";
      };

      network = {
        # drop Gratuitous ARP frames to prevent ARP poisoning
        # this can cause issues when ARP proxies are used in the network
        arp.drop-gratuitous = mkPreset false;

        # Do not ignore all ICMP requests so that this device can be pinged
        icmp.ignore-all = mkPreset false;
      };
    };

    filesystems = {
      normal = {
        # noexec on /home can be very inconvenient for desktops.
        "/home".options."noexec" = mkPreset false;

        # Some applications may need to be executable in /tmp.
        "/tmp".options."noexec" = mkPreset false;

        # noexec on /var(/lib) may cause breakage.
        # Because /var is noexec, set exec explicitly in order to override it
        "/var/lib" = {
          enable = mkPreset true;
          options."noexec" = mkPreset false;
          options."exec" = true;
        };
      };

      special = {
        # Disable access restriction on /proc. Fix Gnome/Wayland.
        "/proc".options.hidepid = mkPreset false;
      };
    };

    extras = {
      misc = {
        # (only enables if usbguard.enable is true)
        usbguard = {
          # Enables USB device authorization at boot.
          whitelist-at-boot = mkPreset true;
          # Enables integration with GNOME Shell.
          gnome-integration = mkPreset true;
        };
      };
    };
  };
}
