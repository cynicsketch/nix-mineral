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
  mkPresets,
  ...
}:

{
  nix-mineral = mkPresets {
    settings = {
      kernel = {
        # Enable SAK (Secure Attention Key). SAK prevents keylogging, if used correctly.
        sysrq = "sak";
      };

      system = {
        # Restrict yama ptrace scope to the most secure option.
        # No processes may be traced with ptrace.
        yama = "restricted";

        # Never allow processes to modify their own memory mappings.
        proc-mem-force = "never";
      };
    };

    extras = {
      kernel = {
        # Avoid putting trust in the highly privilege ME system,
        # Intel users should read more about the issue at the below links:
        # https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
        # https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
        # https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
        # https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
        # https://github.com/Kicksecure/security-misc/issues/239
        intelme-kmodules = false;
      };

      system = {
        # Lock the root account. Requires another method of privilege escalation, i.e
        # sudo or doas, and declarative accounts to work properly.
        lock-root = true;

        # Reduce swappiness to bare minimum. May reduce risk of writing sensitive
        # information to disk, but hampers zram performance. Also useless if you do
        # not even use a swap file/partition, i.e zram only setup.
        minimize-swapping = true;

        # Replace systemd-timesyncd with chrony for NTP, and configure chrony for NTS
        # and to use the seccomp filter for security.
        secure-chrony = true;

        # if false, this may break some applications that rely on user namespaces.
        unprivileged-userns = false;
      };

      network = {
        # Disable bluetooth related kernel modules. (breaks bluetooth)
        bluetooth-kmodules = false;

        # if false, may help mitigate TCP reset DoS attacks, but
        # may also harm network performance when at high latencies.
        tcp-window-scaling = false;
      };

      misc = {
        # Replace sudo with doas, doas has a lower attack surface, but is less audited.
        replace-sudo-with-doas = true;
        doas-sudo-wrapper = true;

        # Enable USBGuard, a tool to restrict USB devices.
        # (blocks any USB devices, maybe enable usbguard.whitelist-at-boot)
        usbguard.enable = true;
      };
    };
  };
}
