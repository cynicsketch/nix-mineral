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
  parentCfg,
  cfg,
  ...
}:

let
  filesystemOpts =
    { name, ... }:
    {
      options = {
        enable = l.mkEnableOption "the filesystem mount";

        device = l.mkOption {
          default = name;
          example = "/dev/sda";
          type = l.types.nullOr l.types.str;
          description = "Location of the device.";
        };

        options = l.mkOption {
          default = { };
          example = {
            "bind" = false;
            "nosuid" = false;
            "noexec" = false;
            "nodev" = false;
          };
          description = ''
            Options used to mount the file system.
            If the value is false, the option is disabled.
            If the value is an integer or a string, it is passed as "name=value".
          '';
          type = l.types.attrsOf (
            l.types.oneOf [
              l.types.bool
              l.types.int
              l.types.str
            ]
          );
        };
      };

      config = {
        options = {
          "bind" = l.mkDefault true;
          "nosuid" = l.mkDefault true;
          "noexec" = l.mkDefault true;
          "nodev" = l.mkDefault true;
        };
      };
    };
in
{
  options = {
    enable = l.mkBoolOption ''
      Enable the filesystem hardening utility from nix-mineral.
    '' true;

    normal = l.mkOption {
      description = ''
        Filesystem hardening.

        Sets the device option with the defined name,
        and the options: "bind", "nosuid", "noexec", "nodev" by default.
      '';
      default = { };
      type = l.types.attrsOf (l.types.submodule filesystemOpts);
    };
  };

  config = {
    # Convert filesystemOpts to fileSystems option on nixpkgs
    fileSystems = l.mkIf parentCfg.enable (
      l.mapAttrs (
        name: opts:
        (l.mkIf opts.enable {
          device = l.mkIf (opts.device != null) (l.mkDefault opts.device);
          options = l.mkFilesystemOptions opts.options;
        })
      ) cfg
    );

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
    nix-mineral.filesystems.normal = {
      # noexec on /home can be very inconvenient for desktops.
      # change options."noexec" to false if you want to disable.
      "/home".enable = l.mkDefault true;

      # You do not want to install applications here anyways.
      "/root".enable = l.mkDefault true;

      # Some applications may need to be executable in /tmp.
      # change options."noexec" to false if you want to disable.
      "/tmp".enable = l.mkDefault true;

      # noexec on /var(/lib) may cause breakage.
      # set the option bellow if you want to disable:
      #"/var/lib" = {
      #  enable = true;
      #  options."noexec" = false;
      #  options."exec" = true;
      #};
      "/var".enable = l.mkDefault true;

      "/boot" = l.mkIf (!config.boot.isContainer) {
        enable = l.mkDefault true;
        device = l.mkDefault null;
        options."bind" = false;
      };

      "/srv".enable = true;

      "/etc" = l.mkIf (!config.boot.isContainer) {
        enable = l.mkDefault true;
        options."noexec" = false;
      };
    };
  };
}
