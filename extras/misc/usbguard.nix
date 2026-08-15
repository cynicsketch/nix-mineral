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
  imports = [
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "misc" "usbguard" "enable" ] ''
      This option does not align with the current project scope.

      Replace with `services.usbguard.enable`.

      See:
      https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/security/usbguard.nix
    '')
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "misc" "usbguard" "whitelist-at-boot" ] ''
      This option does not align with the current project scope.

      Replace with `services.usbguard.presentDevicePolicy = "allow";`.

      See:
      https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/security/usbguard.nix
    '')
    (l.mkDeprecatedOptionModule [ "nix-mineral" "extras" "misc" "usbguard" "gnome-integration" ] ''
      This option does not align with the current project scope.

      Replace with:
      `services.usbguard.dbus.enable` and `services.usbguard.IPCAllowedUsers` or `services.usbguard.IPCAllowedGroups`.

      `services.usbguard.dbus.enable` already integrates with GNOME if your user
      is allowed access to the IPC.

      See:
      https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/security/usbguard.nix
    '')
  ];

  options = {
    usbguard = {
      enable = l.mkDeprecatedOption ''
        Enable USBGuard, a tool to restrict USB devices.

        disable to avoid hassle with handling USB devices at all.
      '';

      whitelist-at-boot = l.mkDeprecatedOption ''
        Automatically allow all connected devices at boot in USBGuard.

        If `false`, USB devices will be blocked until USBGuard is configured.

        ::: {.note}
        For laptop users, inbuilt speakers and bluetooth cards may be disabled
        by USBGuard by default, so whitelisting them manually or enabling this
        may solve that.
        :::
      '';

      gnome-integration = l.mkDeprecatedOption ''
        Enable USBGuard dbus daemon and add polkit rules to integrate USBGuard with
        GNOME Shell.

        If you use GNOME, this means that USBGuard automatically
        allows all newly connected devices while unlocked, and blacklists all
        newly connected devices while locked. This is obviously very convenient,
        and is similar behavior to handling USB as ChromeOS and GrapheneOS.
      '';
    };
  };

  config = l.mkIf (cfg.enable == true) {
    services.usbguard = {
      enable = l.mkDefault true;
      presentDevicePolicy = l.mkIf (cfg.whitelist-at-boot == true) (l.mkDefault "allow");
      dbus.enable = l.mkDefault (cfg.gnome-integration == true);
    };
    security.polkit.extraConfig = l.mkIf (cfg.gnome-integration == true) ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.usbguard.Policy1.listRules" ||
             action.id == "org.usbguard.Policy1.appendRule" ||
             action.id == "org.usbguard.Policy1.removeRule" ||
             action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
             action.id == "org.usbguard.Devices1.listDevices" ||
             action.id == "org.usbguard1.getParameter" ||
             action.id == "org.usbguard1.setParameter") &&
             subject.active == true && subject.local == true &&
             subject.isInGroup("wheel")) { return polkit.Result.YES; }
      });
    '';
  };
}
