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
  config,
  ...
}:

{
  options = {
    no-root-securetty = l.mkBoolOption ''
      Use an empty /etc/securetty to prevent root login on tty.

      If set to true, logging in as the root user will fail and throw an error:
      "Login incorrect"
    '' true;
  };

  config = l.mkIf cfg {
    # Enable securetty support in PAM first
    security.pam.services.login.rules.auth."securetty" = {
      enable = l.mkDefault true;
      order = l.mkDefault 1;
      control = l.mkDefault "requisite";
      modulePath = l.mkDefault "${config.security.pam.package}/lib/security/pam_securetty.so";
    };
    environment.etc.securetty.text = ''
      # /etc/securetty: list of terminals on which root is allowed to login.                                                                                           
      # See securetty(5) and login(1).                                                                                                                                 
    '';
  };
}
