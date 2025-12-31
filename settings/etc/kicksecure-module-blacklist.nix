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
    kicksecure-module-blacklist = l.mkBoolOption ''
      Borrow Kicksecure module blacklist.

      "install "foobar" /bin/false" prevents the module from being
      loaded at all. "blacklist "foobar"" prevents the module from being
      loaded automatically at boot, but it can still be loaded afterwards.

      Because the "install /bin/false" method does not register as a regular
      blacklist, this might cause issues with kernel module auditing e.g
      using Lynis. If so, you'll need to generate a whitelist.

      This may have unintended consequences if you require specific drivers,
      and may cause breakage.
    '' true;
  };

  config = l.mkIf cfg {
    environment.etc."modprobe.d/nm-module-blacklist.conf".source = (
      l.fetchGhFile l.sources.module-blacklist
    );
  };
}
