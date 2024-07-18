({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.desktop.doas-sudo-wrapper.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
    Enable doas-sudo wrapper, with nano to utilize rnano as a "safe"
    editor for editing as root.
    '';
  };

  config = mkIf config.nm-overrides.desktop.doas-sudo-wrapper.enable {
    environment.systemPackages = (with pkgs; [ 
      ((pkgs.writeScriptBin "sudo" ''exec doas "$@"''))
      ((pkgs.writeScriptBin "sudoedit" ''exec doas rnano "$@"''))
      ((pkgs.writeScriptBin "doasedit" ''exec doas rnano "$@"''))
      nano
    ]);
  };
})