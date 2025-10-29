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
    neighbor-solicitations = l.mkOption {
      description = ''
        Number of neighbor solicitations to send out per address.

        Set this to `false` to disable this option entirely.
      '';
      default = 0;
      example = false;
      type = l.types.either l.types.bool l.types.int;
    };
  };

  config = l.mkIf (l.typeOf cfg == "int") {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.dad_transmits" = l.mkDefault (toString cfg);
      "net.ipv6.conf.all.dad_transmits" = l.mkDefault (toString cfg);
    };
  };
}
