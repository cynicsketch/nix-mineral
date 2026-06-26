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
  config,
  ...
}:

{
  options = {
    shadow-hashing = l.mkOption {
      description = ''
        Modify hashing rounds for `/etc/shadow`; this doesn't automatically
        rehash your passwords, you'll need to set passwords for your accounts
        again for this to work.

        If you declaratively set passwords with a secret manager, consider
        using a good hashing round count for resilience to password hash cracking.

        Set this to `false` to disable this option entirely.

        ::: {.note}
        By default, this option will set to a value of 8 if yescrypt is used as
        the hashing algorithm for the passwd service in PAM.

        yescrypt is the default hashing algorithm in NixOS for hashes created
        by the `passwd` command for `/etc/shadow`.

        This value was chosen to improve the cracking difficulty compared to
        the default equivalent of 5, while still being conservative in memory
        usage (128mb) to avoid causing major problems.

        It is recommended that you make this value as close to 11 as possible
        given the performance allowed by your system, to improve resilience to
        cracking.

        If yescrypt is not used, this option will do nothing by default and
        you will have to supply your own value.

        Consult respective documentation if you do not use the default yescrypt
        as the hashing algorithm and wish to increase cracking difficulty
        compared to default values.

        See:
        https://man.archlinux.org/man/chpasswd.8.en
        https://linux-audit.com/authentication/linux-password-security-hashing-rounds/
        https://www.openwall.com/lists/yescrypt/2024/03/20/2
        https://github.com/NixOS/nixpkgs/issues/112371
        :::
      '';
      default = (
        if config.security.pam.services.passwd.rules.password."unix".settings.yescrypt then 8 else false
      );
      example = false;
      type = l.types.either l.types.bool l.types.int;
    };
  };

  config = l.mkIf (l.typeOf cfg == "int") {
    security.pam.services = {
      passwd.rules.password."unix".settings.rounds = l.mkDefault (toString cfg);
    };
  };
}
