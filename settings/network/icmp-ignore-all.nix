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
    icmp-ignore-all = l.mkBoolOption ''
      Set to true to ignore all ICMPv6 and ICMPv4 echo and timestamp requests.
      Makes system slightly harder to enumerate on a network.
      You will not be able to ping this computer with ICMP packets if this is
      enabled.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv6.icmp.echo_ignore_all" = l.mkDefault "1";
      "net.ipv4.icmp_echo_ignore_all" = l.mkDefault "1";
    };
  };
}
