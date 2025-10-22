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
    icmp-secure-redirect = l.mkBoolOption ''
      Use secure ICMP redirects by default. Helpful only if ICMP redirects are
      reenabled, otherwise this does nothing. Not harmful to leave enabled
      even if unnecessary.
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.secure_redirects" = l.mkOverride 900 "1";
      "net.ipv4.conf.default.secure_redirects" = l.mkOverride 900 "1";
    };
  };
}
