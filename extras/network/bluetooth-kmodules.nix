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

  config = {
    nix-mineral.settings.kernel.modules = l.mkIf (!cfg) {
      bluetooth = l.mkDefault false;
      bluetooth_6lowpan = l.mkDefault false;
      bt3c_cs = l.mkDefault false;
      btbcm = l.mkDefault false;
      btintel = l.mkDefault false;
      btmrvl = l.mkDefault false;
      btmrvl_sdio = l.mkDefault false;
      btmtk = l.mkDefault false;
      btmtksdio = l.mkDefault false;
      btmtkuart = l.mkDefault false;
      btnxpuart = l.mkDefault false;
      btqca = l.mkDefault false;
      btrsi = l.mkDefault false;
      btrtl = l.mkDefault false;
      btsdio = l.mkDefault false;
      btusb = l.mkDefault false;
      virtio_bt = l.mkDefault false;
    };
  };
}
