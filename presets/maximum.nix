{
  mkPreset,
  ...
}:

{
  nix-mineral = {
    extras = {
      kernel = {
        # Avoid putting trust in the highly privilege ME system,
        # Intel users should read more about the issue at the below links:
        # https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
        # https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
        # https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
        # https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
        # https://github.com/Kicksecure/security-misc/issues/239
        intelme-kmodules = mkPreset false;
      };

      system = {
        # Lock the root account. Requires another method of privilege escalation, i.e
        # sudo or doas, and declarative accounts to work properly.
        lock-root = mkPreset true;

        # Reduce swappiness to bare minimum. May reduce risk of writing sensitive
        # information to disk, but hampers zram performance. Also useless if you do
        # not even use a swap file/partition, i.e zram only setup.
        minimize-swapping = mkPreset true;

        # Replace systemd-timesyncd with chrony for NTP, and configure chrony for NTS
        # and to use the seccomp filter for security.
        secure-chrony = mkPreset true;

        # Enable SAK (Secure Attention Key). SAK prevents keylogging, if used correctly.
        sysrq-sak = mkPreset true;
      };

      network = {
        # Disable bluetooth related kernel modules. (breaks bluetooth)
        bluetooth-kmodules = mkPreset false;

        # if false, may help mitigate TCP reset DoS attacks, but
        # may also harm network performance when at high latencies.
        tcp-window-scaling = mkPreset false;
      };

      misc = {
        # Replace sudo with doas, doas has a lower attack surface, but is less audited.
        replace-sudo-with-doas = mkPreset true;
        doas-sudo-wrapper = mkPreset true;

        # Enable USBGuard, a tool to restrict USB devices.
        # (blocks any USB devices, maybe enable usbguard.whitelist-at-boot)
        usbguard.enable = mkPreset true;
      };
    };
  };
}
