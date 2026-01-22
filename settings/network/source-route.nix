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
    source-route = l.mkBoolOption ''
      Disable source routing if set to false, since it allows for redirecting
      network traffic and potentially creating a man in the middle attack.

      ::: {.note}
      See:
      - https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-server_security-disable-source-routing
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.accept_source_route" = l.mkDefault "0";
      "net.ipv4.conf.default.accept_source_route" = l.mkDefault "0";
      "net.ipv6.conf.all.accept_source_route" = l.mkDefault "0";
      "net.ipv6.conf.default.accept_source_route" = l.mkDefault "0";
    };
  };
}
