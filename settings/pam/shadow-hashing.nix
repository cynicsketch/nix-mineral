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
    shadow-hashing = l.mkOption {
      description = ''
        Modify hashing rounds for /etc/shadow; this doesn't automatically
        rehash your passwords, you'll need to set passwords for your accounts
        again for this to work.

        If you declaratively set passwords with a secret manager, consider
        using a good number (65536) of hashing rounds or more for resilience to
        password cracking.

        Set this to `false` to disable this option entirely.
      '';
      default = 65536;
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
