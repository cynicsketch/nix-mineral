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
  pkgs,
  config,
  ...
}:

{
  imports = [
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "misc" "doas-sudo-wrapper" ] ''
      This option does not align with the current project scope and the doas port is unmaintained.
      Please use a different tool to get admin privileges.
    '')
  ];

  options = {
    doas-sudo-wrapper = l.mkDeprecatedOption ''
      This option does not fit the project's current vision. The doas port
      in NixOS is unmaintained and not recommended for production use.

      Creates a wrapper for doas to simulate sudo, with nano to utilize rnano as
      editor for editing as root.
    '';
  };

  config = l.mkIf (cfg == true) {
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "sudo" ''
        exec ${config.security.wrapperDir}/doas "$@"
      '')
      (writeShellScriptBin "sudoedit" ''
        exec ${config.security.wrapperDir}/doas ${l.getExe' nano "rnano"} "$@"
      '')
      (writeShellScriptBin "doasedit" ''
        exec ${config.security.wrapperDir}/doas ${l.getExe' nano "rnano"} "$@"
      '')
    ];
  };
}
