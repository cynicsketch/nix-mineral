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
    tcp-sack = l.mkBoolOption ''
      Set to false to disable TCP SACK, which has been used for DoS attacks
      and been exploited in the past.

      Rarely used, but can reduce networking performance if disabled in certain
      applications.

      Additional reading:
      https://github.com/Netflix/security-bulletins/blob/master/advisories/third-party/2019-001.md
      https://serverfault.com/questions/10955/when-to-turn-tcp-sack-off
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "net.ipv4.tcp_dsack" = l.mkDefault "0";
      "net.ipv4.tcp_fack" = l.mkDefault "0";
      "net.ipv4.tcp_sack" = l.mkDefault "0";
    };
  };
}
