({ config, lib, pkgs, ... }:

with lib;     
{
  options.nm-overrides.software-choice.doas-no-sudo.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Replace sudo with doas.
    '';
  };

  config = mkIf config.nm-overrides.software-choice.doas-no-sudo.enable {
    security.sudo = { enable = false; }; 
    security.doas = { 
      enable = true;
      extraRules = [
        ({
          keepEnv = true;
          persist = true;
          users = [ ("user") ];
        })
      ];
    };
  };
})