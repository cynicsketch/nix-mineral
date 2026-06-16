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
    cis-openssh-hardening = l.mkBoolOption ''
      Apply CIS-compliant OpenSSH server settings.
    '' false;
  };

  config = l.mkIf cfg {
    services.openssh.settings = {
      LogLevel = "INFO"; # CIS 5.2.5
      X11Forwarding = false; # CIS 5.2.6
      MaxAuthTries = 4; # CIS 5.2.7
      IgnoreRhosts = true; # CIS 5.2.8
      HostbasedAuthentication = false; # CIS 5.2.9
      PermitRootLogin = "no"; # CIS 5.2.10
      PermitEmptyPasswords = false; # CIS 5.2.11
      PermitUserEnvironment = false; # CIS 5.2.12
      ClientAliveInterval = 300; # CIS 5.2.16
      ClientAliveCountMax = 3; # CIS 5.2.16
      LoginGraceTime = 60; # CIS 5.2.17
      UsePAM = true; # CIS 5.2.20
      MaxSessions = 4; # CIS 5.2.23
    };

    services.openssh.extraConfig = ''
      # CIS 5.2.21 - disable TCP forwarding
      AllowTcpForwarding no

      # CIS 5.2.22 - configure max startups
      MaxStartups 10:30:60
    '';
  };
}
