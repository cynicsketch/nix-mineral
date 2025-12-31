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
    max-addresses = l.mkOption {
      description = ''
        Number of global unicast IPv6 addresses can be assigned to each interface.

        Set this to `false` to disable this option entirely.
      '';
      default = 1;
      example = false;
      type = l.types.either l.types.bool l.types.int;
    };
  };

  config = l.mkIf (l.typeOf cfg == "int") {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.max_addresses" = l.mkDefault (toString cfg);
      "net.ipv6.conf.all.max_addresses" = l.mkDefault (toString cfg);
    };
  };
}
