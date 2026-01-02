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
    ssh-hardening = l.mkBoolOption ''
      Use an opinionated SSH hardening config. Complies with ssh-audit.

      Read what everything does first, or else you might get locked out.

      This, for example, prevents root login AND password based login.
    '' false;
  };

  config = l.mkIf cfg {
    services.openssh = {
      extraConfig = ''
        AllowTcpForwarding no
        HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com
        PermitTunnel no
      '';
      settings = {
        Ciphers = [
          "aes128-ctr"
          "aes128-gcm@openssh.com"
          "aes256-ctr,aes192-ctr"
          "aes256-gcm@openssh.com"
        ];
        KbdInteractiveAuthentication = false;
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
        Macs = [
          "hmac-sha2-256-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-512-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };

    };
  };
}
