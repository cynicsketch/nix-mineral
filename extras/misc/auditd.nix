{
  l,
  cfg,
  ...
}: {
  options = {
    auditd =
      l.mkBoolOption ''
        Enable auditd with CIS-compliant audit rules.

        ::: {.note}
        The audit configuration is made immutable. A reboot is required to
        change audit rules after they are loaded.
        :::
      ''
      false;
  };

  config = l.mkIf cfg {
    security.auditd.enable = true;

    security.audit = {
      # CIS 4.1.19 - make audit configuration immutable
      enable = "lock";
      rules = [
        # CIS 4.1.5 - collect date/time modification events
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
        "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
        "-a always,exit -F arch=b64 -S clock_settime -k time-change"
        "-a always,exit -F arch=b32 -S clock_settime -k time-change"
        "-a always,exit -F path=/etc/localtime -F perm=wa -k time-change"

        # CIS 4.1.6 - collect user/group modification events
        # NixOS manages users declaratively so shadow/gshadow/opasswd do not apply
        "-a always,exit -F path=/etc/group -F perm=wa -k identity"
        "-a always,exit -F path=/etc/passwd -F perm=wa -k identity"

        # CIS 4.1.7 - collect network environment modification events
        "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale"
        "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale"
        "-a always,exit -F path=/etc/issue -F perm=wa -k system-locale"
        "-a always,exit -F path=/etc/issue.net -F perm=wa -k system-locale"
        "-a always,exit -F path=/etc/hosts -F perm=wa -k system-locale"
        "-a always,exit -F path=/etc/hostname -F perm=wa -k system-locale"

        # CIS 4.1.8 - collect MAC modification events
        "-a always,exit -F path=/etc/apparmor/ -F perm=wa -k MAC-policy"
        "-a always,exit -F path=/etc/apparmor.d/ -F perm=wa -k MAC-policy"

        # CIS 4.1.9 - collect login/logout events
        # NixOS does not use lastlog/pam_faillock/faillog/tallylog by default

        # CIS 4.1.10 - collect session initiation events
        # /var/run/utmp is not present at sysinit time (what this service runs as) so cannot be watched
        "-a always,exit -F path=/var/log/wtmp -F perm=wa -k logins"
        "-a always,exit -F path=/var/log/btmp -F perm=wa -k logins"

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
        "-a always,exit -F path=/etc/sudoers -F perm=wa -k scope"
        "-a always,exit -F path=/etc/sudoers.d/ -F perm=wa -k scope"

        # CIS 4.1.17 - collect sudo command execution
        # /run/wrappers/bin/sudo does not exist at sysinit time
        # audit all execve by root on behalf of a regular user instead
        "-a always,exit -F arch=b64 -S execve -F uid=0 -F auid>=1000 -F auid!=4294967295 -k actions"
        "-a always,exit -F arch=b32 -S execve -F uid=0 -F auid>=1000 -F auid!=4294967295 -k actions"

        # CIS 4.1.18 - collect kernel module loading events
        # NixOS does not place kmod tools at /sbin so syscall rules are used instead
        "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
        "-a always,exit -F arch=b32 -S init_module -S delete_module -k modules"
      ];
    };
  };
}
