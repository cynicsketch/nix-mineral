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
    ip-forwarding = l.mkBoolOption ''
      Enable or disable IP forwarding.

      ::: {.warning}
      if false, this may cause issues with certain VM networking,
      and must be true if the system is meant to function as a router.
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.
      "net.ipv4.ip_forward" = l.mkDefault "0";
      "net.ipv4.conf.all.forwarding" = l.mkOverride 900 "0";
      "net.ipv4.conf.default.forwarding" = l.mkDefault "0";
      "net.ipv6.conf.all.forwarding" = l.mkDefault "0";
      "net.ipv6.conf.default.forwarding" = l.mkDefault "0";
    };
  };
}
