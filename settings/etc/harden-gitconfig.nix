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
    harden-gitconfig = l.mkBoolOption ''
      Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
      by default for better git security.
    '' true;
  };

  imports = [
    (l.mkRenamedOptionModule
      [ "nix-mineral" "settings" "etc" "kicksecure-gitconfig" ]
      [ "nix-mineral" "settings" "etc" "harden-gitconfig" ]
    )
  ];

  config = l.mkIf cfg {
    programs.git.config = {
      core.symlinks = l.mkDefault false;
      transfer.fsckobjects = l.mkDefault true;
      fetch.fsckobjects = l.mkDefault true;
      receive.fsckobjects = l.mkDefault true;
    };

    environment.etc.gitconfig.text = l.mkIf (!config.programs.git.enable) (
      l.concatMapStringsSep "\n" l.generators.toGitINI config.programs.git.config
    );
  };
}
