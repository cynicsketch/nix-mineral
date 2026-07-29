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
  options = {
    doas-sudo-wrapper = l.mkBoolOption ''
      THIS OPTION IS NOW DEPRECATED. INFORMATION BELOW IS RETAINED FOR
      FUTURE REFERENCE, AND THIS OPTION IS SCHEDULED TO BE REMOVED PENDING THE
      NEXT RELEASE.

      This option does not fit the project's current vision. The doas port
      in NixOS is unmaintained and not recommended for production use.
    '' false;
  };

  config = l.mkIf cfg {
    warnings = l.optional cfg ''
      The option `nix-mineral.extras.misc.doas-sudo-wrapper` is deprecated due to not
      aligning with current project scope as well as the doas port being unmaintained,
      and will be removed in a future release.

      Please use a different tool to get admin privliges.
    '';
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
