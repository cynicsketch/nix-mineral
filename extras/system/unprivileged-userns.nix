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
    unprivileged-userns = l.mkBoolOption ''
      Enable or disable unprivileged user namespaces.
      It has been the cause of many privilege escalation vulnerabilities,
      but can cause breakage. It is left enabled by default now because
      the benefits of rootless sandboxing in Chromium, unprivileged
      containers, and bubblewrap among many other applications, combined
      with the increase maturity of unprivileged namespaces as of Oct 2025.
      If false, this may break some applications that rely on user namespaces.
    '' true;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = l.mkDefault "0";
    };
  };
}
