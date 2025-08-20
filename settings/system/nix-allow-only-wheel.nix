{
  l,
  cfg,
  ...
}:

{
  options = {
    nix-allow-only-wheel = l.mkBoolOption ''
      Limit access to nix commands to users with the "wheel" group. ("sudoers")
      if false, may be useful for allowing a non-wheel user to, for example, use devshell.
    '' true;
  };

  config = l.mkIf cfg {
    nix.settings.allowed-users = l.mkDefault [ "@wheel" ];
  };
}
