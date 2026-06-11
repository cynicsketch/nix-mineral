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
  mkPresets,
  ...
}: {
  # CIS Benchmark Compliance Preset
  #
  # Implements Center for Internet Security (CIS) benchmark requirements.
  # Archive: https://ia903101.us.archive.org/view_archive.php?archive=/1/items/cis-benchmarks/CIS_Benchmarks.zip&file=CIS_Benchmarks%2FLinux%2FCIS_Distribution_Independent_Linux_Benchmark_v2.0.0.pdf

  assertions = [
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
      assertion = !config.services.dhcpd4.enable;
      message = "CIS 2.2.5: DHCP server (dhcpd4) must not be enabled";
    }
    {
      assertion = !config.services.dhcpd6.enable;
      message = "CIS 2.2.5: DHCP server (dhcpd6) must not be enabled";
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
      misc = {
        apparmor = true; # CIS 1.6.1.1 - enable AppArmor
      };
    };
  };

  environment.etc = {
    # CIS 1.7.1.1 - message of the day
    "motd".text = ''
      Authorized uses only. All activity may be monitored and reported.
    '';

    # CIS 1.7.1.3 - remote login warning banner
    "issue.net".text = ''
      Authorized uses only. All activity may be monitored and reported.
    '';

    # CIS 3.4.1-3.4.4 - disable uncommon network protocols
    "modprobe.d/cis-uncommon-protocols.conf".text = ''
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
  };

  # TODO: Determine if instead we should only assert that these services are enabled.
  # CIS 4.1.2, 4.1.3 - install and enable auditd
  security.auditd.enable = true;

  security.audit = {
    enable = true;
    rules = [
      # CIS 4.1.5 - collect date/time modification events
      "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
      "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
      "-a always,exit -F arch=b64 -S clock_settime -k time-change"
      "-a always,exit -F arch=b32 -S clock_settime -k time-change"
      "-w /etc/localtime -p wa -k time-change"

      # CIS 4.1.6 - collect user/group modification events
      "-w /etc/group -p wa -k identity"
      "-w /etc/passwd -p wa -k identity"
      "-w /etc/gshadow -p wa -k identity"
      "-w /etc/shadow -p wa -k identity"
      "-w /etc/security/opasswd -p wa -k identity"

      # CIS 4.1.7 - collect network environment modification events
      "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
      "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"
      "-w /etc/issue -p wa -k system-locale"
      "-w /etc/issue.net -p wa -k system-locale"
      "-w /etc/hosts -p wa -k system-locale"
      "-w /etc/hostname -p wa -k system-locale"

      # CIS 4.1.8 - collect MAC modification events
      "-w /etc/apparmor/ -p wa -k MAC-policy"
      "-w /etc/apparmor.d/ -p wa -k MAC-policy"

      # CIS 4.1.9 - collect login/logout events
      "-w /var/log/faillog -p wa -k logins"
      "-w /var/log/lastlog -p wa -k logins"
      "-w /var/log/tallylog -p wa -k logins"

      # CIS 4.1.10 - collect session initiation events
      "-w /var/run/utmp -p wa -k session"
      "-w /var/log/wtmp -p wa -k logins"
      "-w /var/log/btmp -p wa -k logins"

      # CIS 4.1.11 - collect DAC permission modification events
      "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
      "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod"
      "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"
      "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod"
      "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"
      "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod"

      # CIS 4.1.12 - collect unauthorized file access attempts
      "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
      "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access"
      "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"
      "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access"

      # CIS 4.1.14 - collect successful file system mount events
      "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"
      "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts"

      # CIS 4.1.15 - collect file deletion events
      "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"

      # CIS 4.1.16 - collect sudoers modification events
      "-w /etc/sudoers -p wa -k scope"
      "-w /etc/sudoers.d/ -p wa -k scope"

      # CIS 4.1.17 - collect sudo command execution
      "-w /var/log/sudo.log -p wa -k actions"

      # CIS 4.1.18 - collect kernel module loading events
      "-w /sbin/insmod -p x -k modules"
      "-w /sbin/rmmod -p x -k modules"
      "-w /sbin/modprobe -p x -k modules"
      "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
      "-a always,exit -F arch=b32 -S init_module -S delete_module -k modules"

      # CIS 4.1.19 - make audit configuration immutable
      "-e 2"
    ];
  };

  services.openssh.settings = {
    LogLevel = "INFO"; # CIS 5.2.5 - appropriate log level
    X11Forwarding = false; # CIS 5.2.6 - disable X11 forwarding
    MaxAuthTries = 4; # CIS 5.2.7 - limit authentication attempts
    IgnoreRhosts = true; # CIS 5.2.8 - ignore rhosts
    HostbasedAuthentication = false; # CIS 5.2.9 - disable host-based auth
    PermitRootLogin = "no"; # CIS 5.2.10 - disable root login
    PermitEmptyPasswords = false; # CIS 5.2.11 - reject empty passwords
    PermitUserEnvironment = false; # CIS 5.2.12 - reject user environment
    ClientAliveInterval = 300; # CIS 5.2.16 - idle timeout interval
    ClientAliveCountMax = 3; # CIS 5.2.16 - idle timeout count
    LoginGraceTime = 60; # CIS 5.2.17 - login grace time
    UsePAM = true; # CIS 5.2.20 - enable PAM
    MaxSessions = 4; # CIS 5.2.23 - limit sessions
  };

  services.openssh.extraConfig = ''
    # CIS 5.2.21 - disable TCP forwarding
    AllowTcpForwarding no

    # CIS 5.2.22 - configure max startups
    MaxStartups 10:30:60
  '';

  # CIS 5.4.4 - default user umask 027 or more restrictive
  # CIS 5.4.5 - default shell timeout 900 seconds or less
  environment.interactiveShellInit = ''
    umask 027
    TMOUT=900
    readonly TMOUT
    export TMOUT
  '';

  # CIS 6.2.x - declarative user management
  users.mutableUsers = false;
}
