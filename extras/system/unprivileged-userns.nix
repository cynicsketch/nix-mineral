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
  imports = [
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "system" "unprivileged-userns" ] ''
      This option does nothing on the upstream NixOS kernel.
    '')
  ];

  options = {
    unprivileged-userns = l.mkDeprecatedOption ''
      This option DOES NOT work on the upstream NixOS kernel. Setting this
      does nothing because the requisite sysctl does not exist.

      Enable or disable unprivileged user namespaces.

      It has been the cause of many privilege escalation vulnerabilities,
      but can cause breakage. If `false`, this may break some applications
      that rely on user namespaces.
    '';
  };

  config = l.mkIf (cfg == false) {
    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = l.mkDefault "0";
    };
  };
}
