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

{ pkgs, nixosModule }:

pkgs.testers.runNixOSTest {
  name = "mineral-settings-network";

  nodes.machine = {
    imports = [ nixosModule ];
    nix-mineral.enable = true;
    nix-mineral.settings.network = {
      syncookies = true;
      rfc1337 = true;
      source-route = false;
      rp-filter = true;
      log-martians = true;
      shared-media = false;
      ip-forwarding = false;
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("sysctl -n net.ipv4.tcp_syncookies | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.tcp_rfc1337 | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.accept_source_route | grep -qx 0")
    machine.succeed("sysctl -n net.ipv6.conf.all.accept_source_route | grep -qx 0")
    machine.succeed("sysctl -n net.ipv4.conf.all.rp_filter | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.log_martians | grep -qx 1")
    machine.succeed("sysctl -n net.ipv4.conf.all.shared_media | grep -qx 0")
    machine.succeed("sysctl -n net.ipv4.ip_forward | grep -qx 0")
  '';
}
