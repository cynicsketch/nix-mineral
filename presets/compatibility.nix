{
  config,
  l,
  mkPreset,
  ...
}:

{
  nix-mineral = {
    settings = {
      kernel = {
        # Enabling this option causes a hanging issue on linux kernel 6.13
        # so we only enable it for 6.14 and later
        amd-iommu-force-isolation = mkPreset (
          l.versionAtLeast (l.getVersion config.boot.kernelPackages.kernel) "6.14"
        );

        # if false, breaks Roseta, among other applications.
        binfmt-misc = mkPreset true;

        # if false, may prevent low resource systems from booting.
        busmaster-bit = mkPreset true;

        # Enable loading of unsigned kernel modules and enable hibernation.
        lockdown = mkPreset false;
        only-signed-modules = mkPreset false;
      };

      system = {
        # allow 32-bit libraries and applications to run.
        multilib = mkPreset true;

        # if false, this may break some applications that rely on user namespaces.
        unprivileged-userns = mkPreset true;
      };
    };

    filesystems = {
      normal = {
        # noexec on /home can be very inconvenient for desktops.
        "/home".options."noexec" = mkPreset false;

        # Some applications may need to be executable in /tmp.
        "/tmp".options."noexec" = mkPreset false;

        # noexec on /var(/lib) may cause breakage.
        "/var/lib" = {
          enable = mkPreset true;
          options."noexec" = mkPreset false;
        };
      };

      special = {
        # Disable access restriction on /proc. Fix Gnome/Wayland.
        "/proc".options.hidepid = mkPreset false;
      };
    };

    extras = {
      misc = {
        # (only enables if usbguard.enable is true)
        usbguard = {
          # Enables USB device authorization at boot.
          whitelist-at-boot = mkPreset true;
          # Enables integration with GNOME Shell.
          gnome-integration = mkPreset true;
        };
      };
    };
  };
}
