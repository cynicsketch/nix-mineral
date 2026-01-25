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
    dnssec = l.mkBoolOption ''
      Make DNS connections fail if not using a DNS server supporting
      DNSSEC.

      ::: {.note}
      Currently does nothing if you don't use systemd-resolved.

      Consider filing a PR if/when similar configuration for other DNS
      resolving software can be added unobtrusively.
      :::
    '' true;
  };

  config = l.mkIf cfg {
    services.resolved.dnssec = l.mkDefault "true";
  };
}
