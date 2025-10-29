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
    router-tweaks = l.mkBoolOption ''
      Tweak router advertisement settings to improve privacy and security.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      # number of Router Solicitations to send until assuming no routers are present
      "net.ipv6.conf.default.router_solicitations" = l.mkDefault "0";
      "net.ipv6.conf.all.router_solicitations" = l.mkDefault "0";

      # do not accept Router Preference from RA
      "net.ipv6.conf.default.accept_ra_rtr_pref" = l.mkDefault "0";
      "net.ipv6.conf.all.accept_ra_rtr_pref" = l.mkDefault "0";

      # learn prefix information in router advertisement
      "net.ipv6.conf.default.accept_ra_pinfo" = l.mkDefault "0";
      "net.ipv6.conf.all.accept_ra_pinfo" = l.mkDefault "0";

      # setting controls whether the system will accept Hop Limit settings from a router advertisement
      "net.ipv6.conf.default.accept_ra_defrtr" = l.mkDefault "0";
      "net.ipv6.conf.all.accept_ra_defrtr" = l.mkDefault "0";

      # router advertisements can cause the system to assign a global unicast address to an interface
      "net.ipv6.conf.default.autoconf" = l.mkDefault "0";
      "net.ipv6.conf.all.autoconf" = l.mkDefault "0";
    };
  };
}
