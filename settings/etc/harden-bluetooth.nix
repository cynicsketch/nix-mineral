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
    harden-bluetooth = l.mkBoolOption ''
      Borrow Kicksecure bluetooth configuration for better bluetooth privacy
      and security.

      Disables bluetooth automatically when not connected to any device.
    '' true;
  };

  imports = [
    (l.mkRenamedOptionModule
      [ "nix-mineral" "settings" "etc" "kicksecure-bluetooth" ]
      [ "nix-mineral" "settings" "etc" "harden-bluetooth" ]
    )
  ];

  config = l.mkIf cfg {
    hardware.bluetooth.settings = {
      General = {
        # How long to stay in pairable mode before going back to non-discoverable
        # The value is in seconds. Default is 0.
        # 0 = disable timer, i.e. stay pairable forever
        PairableTimeout = l.mkDefault 30;
        # How long to stay in discoverable mode before going back to non-discoverable
        # The value is in seconds. Default is 180, i.e. 3 minutes.
        # 0 = disable timer, i.e. stay discoverable forever
        DiscoverableTimeout = l.mkDefault 30;
        # Maximum number of controllers allowed to be exposed to the system.
        # Default=0 (unlimited)
        MaxControllers = l.mkDefault 1;
        # How long to keep temporary devices around
        # The value is in seconds. Default is 30.
        # 0 = disable timer, i.e. never keep temporary devices
        TemporaryTimeout = l.mkDefault 0;
        # network/on: A device will only accept advertising packets from peer
        # devices that contain private addresses. It may not be compatible with some
        # legacy devices since it requires the use of RPA(s) all the time.
        Privacy = l.mkDefault "network";
      };
      # AutoEnable defines option to enable all controllers when they are found.
      # This includes adapters present on start as well as adapters that are plugged
      # in later on. Defaults to 'true'.
      Policy.AutoEnable = l.mkDefault false;
    };
  };
}
