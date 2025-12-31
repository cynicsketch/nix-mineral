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
    bluetooth-kmodules = l.mkBoolOption ''
      Enable bluetooth related kernel modules.
    '' true;
  };

  config = l.mkIf (!cfg) {
    environment.etc."modprobe.d/nm-disable-bluetooth.conf" = {
      text = ''
        install bluetooth /usr/bin/disabled-bluetooth-by-security-misc
        install bluetooth_6lowpan  /usr/bin/disabled-bluetooth-by-security-misc
        install bt3c_cs /usr/bin/disabled-bluetooth-by-security-misc
        install btbcm /usr/bin/disabled-bluetooth-by-security-misc
        install btintel /usr/bin/disabled-bluetooth-by-security-misc
        install btmrvl /usr/bin/disabled-bluetooth-by-security-misc
        install btmrvl_sdio /usr/bin/disabled-bluetooth-by-security-misc
        install btmtk /usr/bin/disabled-bluetooth-by-security-misc
        install btmtksdio /usr/bin/disabled-bluetooth-by-security-misc
        install btmtkuart /usr/bin/disabled-bluetooth-by-security-misc
        install btnxpuart /usr/bin/disabled-bluetooth-by-security-misc
        install btqca /usr/bin/disabled-bluetooth-by-security-misc
        install btrsi /usr/bin/disabled-bluetooth-by-security-misc
        install btrtl /usr/bin/disabled-bluetooth-by-security-misc
        install btsdio /usr/bin/disabled-bluetooth-by-security-misc
        install btusb /usr/bin/disabled-bluetooth-by-security-misc
        install virtio_bt /usr/bin/disabled-bluetooth-by-security-misc
      '';
    };
  };
}
