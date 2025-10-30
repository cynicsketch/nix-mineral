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
    log-martians = l.mkBoolOption ''
      Log packets with impossible addresses to kernel log
      No active security benefit, just makes it easier to
      spot a DDOS/DOS by giving extra logs
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      # NOTE: `mkOverride 900` is used when a default value is already defined in NixOS.
      "net.ipv4.conf.default.log_martians" = l.mkOverride 900 "1";
      "net.ipv4.conf.all.log_martians" = l.mkOverride 900 "1";
    };
  };
}
