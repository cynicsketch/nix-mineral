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
  l,
  cfg,
  ...
}:

{
  options = {
    lockdown = l.mkOption {
      description = ''
        Enable linux kernel lockdown, this blocks loading of unsigned kernel modules
        and breaks hibernation.

        ::: {.note}
        THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
        FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
        NEXT RELEASE.

        This currently does nothing as the default NixOS kernel config does not
        enable Linux kernel lockdown as of 16/03/26.

        See:
        https://github.com/NixOS/nixpkgs/blob/baeac6edff1b03f0ecd063b8fe48e9742d0527e7/pkgs/os-specific/linux/kernel/common-config.nix#L830
        https://github.com/cynicsketch/nix-mineral/issues/125

        If `false`, you probably want to disable {option}`nix-mineral.settings.kernel.only-signed-modules`.
        :::
      '';
      default = null;
      example = false;
      type = l.types.nullOr l.types.bool;
    };
  };

  config = l.mkMerge [
    (l.mkIf (l.typeOf cfg == "bool") {
      warnings = [
        ''
          The option `nix-mineral.settings.kernel.lockdown` is deprecated
          due to being non-functional and will be removed in a future release.

          Please remove this setting from your NixOS configuration.
        ''
      ];
    })
    (l.mkIf (cfg == true) {
      boot.kernelParams = [
        "lockdown=confidentiality"
      ];
    })
  ];
}
