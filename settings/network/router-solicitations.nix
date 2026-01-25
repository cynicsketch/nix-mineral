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
    router-solicitations = l.mkOption {
      description = ''
        Number of IPv6 Router Solicitations to send until assuming no routers
        are present.

        Setting to 0 limits outgoing traffic on the network,
        and reduces the frequecy of IPv6 router advertisements received.

        See RFC4681 for details.

        Set this to `false` to disable this option entirely.

        ::: {.note}
        There is no point to setting this number above 0 if
        {option}`nix-mineral.settings.network.router-advertisements` is set to `off`.
        :::
      '';
      default = 0;
      example = false;
      type = l.types.either l.types.bool l.types.int;
    };
  };

  config = l.mkIf (l.typeOf cfg == "int") {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.router_solicitations" = l.mkDefault (toString cfg);
      "net.ipv6.conf.all.router_solicitations" = l.mkDefault (toString cfg);
    };
  };
}
