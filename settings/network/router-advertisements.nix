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
    router-advertisements = l.mkBoolOption ''
      Enable or disable all IPv6 router advertisements which are accepted.
      Malicious router advertisements have the potential to create a MITM
      attack by modifying the default gateway, cause a DoS/DDoS attack when
      flooded, or initiate unauthorized IPv6 access.

      Router advertisements are never authenticated, and can be sent and
      received by any device on the local network.

      Setting to false may cause issues with IPv6 address autoconfiguration or
      host discovery.

      See:
      https://datatracker.ietf.org/doc/html/rfc6104
      https://datatracker.ietf.org/doc/html/rfc6105
      https://archive.conference.hitb.org/hitbsecconf2012kul/materials/D1T2%20-%20Marc%20Heuse%20-%20IPv6%20Insecurity%20Revolutions.pdf
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "net.ipv6.conf.default.accept_ra" = l.mkDefault "0";
      "net.ipv6.conf.all.accept_ra" = l.mkDefault "0";
    };
  };
}
