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
    rfc1337 = l.mkBoolOption ''
      RFC1337 protects from TIME-WAIT assassination attacks by dropping TCP
      RST packets when in the TIME-WAIT state.

      This protects against some potention DoS attacks which could cause
      TCP connections to drop given specific circumstances or crafted packets.

      Additional reference:
      https://datatracker.ietf.org/doc/html/rfc1337
      https://serverfault.com/questions/787624/why-isnt-net-ipv4-tcp-rfc1337-enabled-by-default
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv4.tcp_rfc1337" = l.mkDefault "1";
    };
  };
}
