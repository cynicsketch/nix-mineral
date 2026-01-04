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
    warn-panic = l.mkBoolOption ''
      Be extra paranoid of potential kernel exploitation by inducing kernel
      panics on kernel warns and above.

      This will cause massive instability in the event of any bugs in the
      kernel.
    '' false;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl."kernel.warn_limit" = l.mkDefault "1";
  };
}
