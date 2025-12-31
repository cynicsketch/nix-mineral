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
    coredump = l.mkBoolOption ''
      Disable core dumps everywhere. Core dumps contain a programs memory,
      usually after a crash, which could include sensitive information
      including encryption keys being written to the disk without any
      protection.

      This disables core dumps using a combination of sysctl, PAM, and
      systemd. These are grouped together, because the disablement of
      any individual one of these might otherwise make available a bypass.

      You might need core dumps when debugging crashing programs.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "fs.suid_dumpable" = l.mkDefault "0";
      "kernel.core_pattern" = l.mkDefault "|/bin/false";
    };
    security.pam.loginLimits = [
      {
        domain = l.mkDefault "*";
        item = l.mkDefault "core";
        type = l.mkDefault "hard";
        value = l.mkDefault "0";
      }
    ];
    # Don't store coredumps from systemd-coredump.
    systemd.coredump.extraConfig = ''
      Storage=none
    '';
  };
}
