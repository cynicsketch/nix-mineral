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
    router-advertisements-restrict = l.mkBoolOption ''
      Restrict the parameters of IPv6 router advertisements which are accepted.
      Malicious router advertisements have the potential to create a MITM
      attack by modifying the default gateway, cause a DoS/DDoS attack when
      flooded, or initiate unauthorized IPv6 access.

      Router advertisements are never authenticated, and can be sent and
      received by any device on the local network.

      This option does nothing if all router advertisements are disabled with
      nix-mineral.settings.network.router-advertisements = false

      Setting to true may cause issues with IPv6 address autoconfiguration or
      host discovery.

      See:
      https://datatracker.ietf.org/doc/html/rfc6104
      https://datatracker.ietf.org/doc/html/rfc6105
      https://archive.conference.hitb.org/hitbsecconf2012kul/materials/D1T2%20-%20Marc%20Heuse%20-%20IPv6%20Insecurity%20Revolutions.pdf
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
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
