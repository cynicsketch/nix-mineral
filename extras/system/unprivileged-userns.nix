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
    unprivileged-userns = l.mkOption {
      description = ''
        THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
        FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
        NEXT RELEASE.

        This option DOES NOT work on the upstream NixOS kernel. Setting this
        does nothing because the requisite sysctl does not exist.
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
          The option `nix-mineral.extras.system.unprivileged-userns` is deprecated
          due to being non-functional and will be removed in a future release.

          Please remove this setting from your NixOS configuration.
        ''
      ];
    })
    (l.mkIf (cfg == false) {
      boot.kernel.sysctl = {
        "kernel.unprivileged_userns_clone" = l.mkDefault "0";
      };
    })
  ];
}
