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
    intelme-kmodules = l.mkBoolOption ''
      Intel ME related kernel modules.

      Disable this to avoid putting trust in the highly privilege ME system,
      but there are potentially other consequences.

      ::: {.tip}
      If you use an AMD system, you can disable this without negative consequence
      and reduce attack surface.
      :::

      ::: {.note}
      Intel users should read more about the issue at the below links:
      - https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
      - https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
      - https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
      - https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
      - https://github.com/Kicksecure/security-misc/issues/239
      :::
    '' true;
  };

  config = l.mkIf (!cfg) {
    environment.etc."modprobe.d/nm-disable-intelme-kmodules.conf" = {
      text = ''
        install mei /usr/bin/disabled-intelme-by-security-misc
        install mei-gsc /usr/bin/disabled-intelme-by-security-misc
        install mei_gsc_proxy /usr/bin/disabled-intelme-by-security-misc
        install mei_hdcp /usr/bin/disabled-intelme-by-security-misc
        install mei-me /usr/bin/disabled-intelme-by-security-misc
        install mei_phy /usr/bin/disabled-intelme-by-security-misc
        install mei_pxp /usr/bin/disabled-intelme-by-security-misc
        install mei-txe /usr/bin/disabled-intelme-by-security-misc
        install mei-vsc /usr/bin/disabled-intelme-by-security-misc
        install mei-vsc-hw /usr/bin/disabled-intelme-by-security-misc
        install mei_wdt /usr/bin/disabled-intelme-by-security-misc
        install microread_mei /usr/bin/disabled-intelme-by-security-misc
      '';
    };
  };
}
