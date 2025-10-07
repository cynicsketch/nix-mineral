{
  l,
  cfg,
  ...
}:

{
  options = {
    replace-sudo-with-doas = l.mkBoolOption ''
      Replace sudo with doas, doas has a lower attack surface, but is less audited.
    '' false;
  };

  config = l.mkIf cfg {
    security.sudo.enable = l.mkDefault false;
    security.doas = {
      enable = l.mkDefault true;
      extraRules = [
        {
          keepEnv = l.mkDefault true;
          persist = l.mkDefault true;
          users = l.mkDefault [ "wheel" ];
        }
      ];
    };
  };
}
