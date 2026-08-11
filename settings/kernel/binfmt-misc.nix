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
    binfmt-misc = l.mkBoolOption ''
      Enable [binfmt_misc](https://en.wikipedia.org/wiki/Binfmt_misc).

      Set to false to disable binfmt. This option is inert if nothing has
      registered with binfmt before writing the sysctl.

      If `/proc/sys/fs/binfmt_misc` is an empty directory, that means that
      nothing is currently using binfmt_misc. If it is not empty, consider
      checking your system for what may be using it and consider if the
      requisite functionality is necessary for your usecase.

      ::: {.warning}
      If `false`, breaks applications that register with binfmt, such as
      Wine, Java, or AppImages if support is enabled.

      See:
      - https://search.nixos.org/options?channel=unstable&query=binfmt&type=options
      :::

      ::: {.note}
      For more information, read more at the following links:
      - https://docs.kernel.org/admin-guide/binfmt-misc.html
      - https://dfir.ch/posts/today_i_learned_binfmt_misc/
      - https://nvd.nist.gov/vuln/detail/CVE-2026-48831 (disputed)
      :::
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "fs.binfmt_misc.status" = l.mkDefault "0";
    };
  };
}
