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
    tiocsti = l.mkBoolOption ''
      If false, disable TIOCSTI because it's used to inject arbitrary
      characters and potentially lead to privilege escalation.

      Already disabled by default on modern (>=6.2) Linux kernel versions,
      but included for future reference.

      May break outdated screen readers relying on legacy functionality, but
      because of the above reasoning, this will never be considered for
      the compatibility preset.

      See:
      https://lore.kernel.org/lkml/20221228205726.rfevry7ud6gmttg5@begin/T/
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "dev.tty.legacy_tiocsti" = "0";
    };
  };
}
