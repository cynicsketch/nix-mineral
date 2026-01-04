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
    oops-panic = l.mkBoolOption ''
      Intentionally induce kernel panics on "oops" errors and above, to
      limit the extent of certain exploits which trigger kernel oopses.

      This might cause stability issues with certain poorly written drivers
      that aren't malicious. If you experience random kernel panics, consider
      disabling this.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernelParams = [
      "oops=panic"
    ];

    # For future reference, the following sysctl accomplishes the same thing
    # but has been excluded for redundancy:
    # boot.kernel.sysctl."kernel.oops_limit" = l.mkDefault "1";
  };
}
