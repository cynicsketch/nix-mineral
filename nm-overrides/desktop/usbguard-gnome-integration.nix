({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.usbguard-gnome-integration.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Enable USBGuard dbus daemon and polkit rules for integration with GNOME
      Shell.
    '';
  };

  config = mkIf config.nm-overrides.usbguard-gnome-integration.enable{
    services.usbguard.dbus.enable = mkForce true;
    security.polkit = { 
      extraConfig = ''
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
  };
})