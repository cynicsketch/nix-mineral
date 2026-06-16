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
  config,
  l,
  mkPresets,
  ...
}: let
  toWarnings = l.concatMap (a: l.optional (!a.assertion) a.message);
in {
  # CIS Benchmark Compliance Preset
  #
  # Implements Center for Internet Security (CIS) benchmark requirements.
  # Archive: https://ia903101.us.archive.org/view_archive.php?archive=/1/items/cis-benchmarks/CIS_Benchmarks.zip&file=CIS_Benchmarks%2FLinux%2FCIS_Distribution_Independent_Linux_Benchmark_v2.0.0.pdf

  warnings = toWarnings [
    # CIS 1.6.1.1 - Ensure SELinux or AppArmor are installed
    {
      assertion = config.security.apparmor.enable;
      message = ''
        CIS 1.6.1.1: Mandatory Access Control (MAC) is required.
        SELinux is not available on NixOS. AppArmor must be enabled.
        Set: security.apparmor.enable = true
      '';
    }

    # CIS 2.2.3 - Ensure Avahi Server is not enabled
    {
      assertion = !config.services.avahi.enable;
      message = "CIS 2.2.3: Avahi server must not be enabled";
    }

    # CIS 2.2.4 - Ensure CUPS is not enabled
    {
      assertion = !config.services.printing.enable;
      message = "CIS 2.2.4: CUPS must not be enabled";
    }

    # CIS 2.2.5 - Ensure DHCP Server is not enabled
    {
      assertion = !config.services.kea.dhcp4.enable;
      message = "CIS 2.2.5: DHCP server (kea.dhcp4) must not be enabled";
    }
    {
      assertion = !config.services.kea.dhcp6.enable;
      message = "CIS 2.2.5: DHCP server (kea.dhcp6) must not be enabled";
    }

    # CIS 2.2.8 - Ensure DNS Server is not enabled
    {
      assertion = !config.services.bind.enable;
      message = "CIS 2.2.8: DNS server must not be enabled";
    }

    # CIS 2.2.9 - Ensure FTP Server is not enabled
    {
      assertion = !config.services.vsftpd.enable;
      message = "CIS 2.2.9: FTP server must not be enabled";
    }

    # CIS 2.2.10 - Ensure HTTP server is not enabled
    {
      assertion = !config.services.httpd.enable;
      message = "CIS 2.2.10: HTTP server (Apache) must not be enabled";
    }
    {
      assertion = !config.services.nginx.enable;
      message = "CIS 2.2.10: HTTP server (nginx) must not be enabled";
    }

    # CIS 2.2.11 - Ensure IMAP and POP3 server is not enabled
    {
      assertion = !config.services.dovecot2.enable;
      message = "CIS 2.2.11: IMAP/POP3 server must not be enabled";
    }

    # CIS 2.2.12 - Ensure Samba is not enabled
    {
      assertion = !config.services.samba.enable;
      message = "CIS 2.2.12: Samba must not be enabled";
    }
    {
      assertion = !config.services.samba-wsdd.enable;
      message = "CIS 2.2.12: Samba WSDD must not be enabled";
    }

    # CIS 2.2.13 - Ensure HTTP Proxy Server is not enabled
    {
      assertion = !config.services.squid.enable;
      message = "CIS 2.2.13: HTTP proxy server must not be enabled";
    }

    # CIS 2.2.14 - Ensure SNMP Server is not enabled
    {
      assertion = !(config.services.snmpd.enable or false);
      message = "CIS 2.2.14: SNMP server must not be enabled";
    }

    # CIS 2.2.15 - Ensure mail transfer agent is configured for local-only mode
    {
      assertion = !(config.services.postfix.enable or false);
      message = "CIS 2.2.15: MTA (Postfix) must be local-only or disabled";
    }
    {
      assertion = !(config.services.sendmail.enable or false);
      message = "CIS 2.2.15: MTA (Sendmail) must be local-only or disabled";
    }

    # CIS 2.2.16 - Ensure rsync service is not enabled
    {
      assertion = !config.services.rsyncd.enable;
      message = "CIS 2.2.16: rsync service must not be enabled";
    }

    # CIS 2.2.17 - Ensure NIS Server is not enabled
    {
      assertion = !(config.services.ypserv.enable or false);
      message = "CIS 2.2.17: NIS server must not be enabled";
    }

    # CIS 6.2.x - User and Group Settings
    {
      assertion = !config.users.mutableUsers;
      message = ''
        CIS 6.2: User accounts must be managed declaratively.
        Set: users.mutableUsers = false
      '';
    }
  ];

  nix-mineral = mkPresets {
    settings = {
      etc = {
        kicksecure-module-blacklist = true; # CIS 1.1.1.x - disable unused filesystems
        kicksecure-issue = true; # CIS 1.7.1.2 - local login warning banner
      };

      debug = {
        coredump = false; # CIS 1.5.1 - restrict core dumps
      };

      entropy = {
        aslr = true; # CIS 1.5.3 - enable ASLR
      };

      network = {
        ip-forwarding = false; # CIS 3.1.1 - disable IP forwarding
        source-route = false; # CIS 3.2.1 - reject source routed packets
        log-martians = true; # CIS 3.2.4 - log suspicious packets
        rp-filter = true; # CIS 3.2.7 - enable reverse path filtering
        syncookies = true; # CIS 3.2.8 - enable TCP SYN cookies
        router-advertisements = "off"; # CIS 3.2.9 - reject IPv6 router advertisements

        icmp = {
          redirect = false; # CIS 3.1.2, 3.2.2 - disable ICMP redirects
          secure-redirect = false; # CIS 3.2.3 - reject secure ICMP redirects
          cast = false; # CIS 3.2.5 - ignore broadcast ICMP requests
          ignore-all = false; # CIS 3.2.5 - only ignore broadcasts, not all
          ignore-bogus = true; # CIS 3.2.6 - ignore bogus ICMP responses
        };
      };

      pam = {
        shadow-hashing = 65536; # CIS 5.3.4 - SHA-512 password hashing
        login-faildelay = 4000000; # CIS 5.3.2 - lockout for failed attempts
        su-wheel-only = true; # CIS 5.6 - restrict su to wheel group
      };
    };

    extras = {
      etc = {
        cis-banners = true; # CIS 1.7.1.1, 1.7.1.3 - login warning banners
      };

      misc = {
        apparmor = true; # CIS 1.6.1.1 - enable AppArmor
        auditd = true; # CIS 4.1.x - enable auditd with CIS rules
        harden-openssh = true; # CIS 5.2.x - harden OpenSSH
      };

      system = {
        mutable-users = true; # CIS 6.2.x - declarative user management
        # CIS 5.4.4 - umask
        umask = {
          enable = true;
          value = "027";
        };
        # CIS 5.4.4 - shell tmout
        tmout = {
          enable = true;
          value = 900;
        };
      };
    };
  };

  # CIS 3.4.1-3.4.4 - disable uncommon network protocols
  environment.etc."modprobe.d/cis-uncommon-protocols.conf".text = ''
    # CIS 3.4.1 - disable DCCP
    install dccp /bin/false
    blacklist dccp

    # CIS 3.4.2 - disable SCTP
    install sctp /bin/false
    blacklist sctp

    # CIS 3.4.3 - disable RDS
    install rds /bin/false
    blacklist rds

    # CIS 3.4.4 - disable TIPC
    install tipc /bin/false
    blacklist tipc
  '';
}
