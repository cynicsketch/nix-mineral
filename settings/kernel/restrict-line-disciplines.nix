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
    restrict-line-disciplines = l.mkBoolOption ''
      Restrict TTY line discipline loading to CAP_SYS_MODULE to prevent
      unprivileged users from loading insecure line disciplines.

      ::: {.note}
      See https://a13xp0p0v.github.io/2017/03/24/CVE-2017-2636.html as an
      example exploit.
      :::
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "dev.tty.ldisc_autoload" = l.mkDefault "0";
    };
  };
}
