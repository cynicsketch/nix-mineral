{
  l,
  cfg,
  ...
}:

{
  options = {
    firewall = l.mkBoolOption ''
      Enables firewall. You may need to tweak your firewall rules depending on
      your usecase. On a desktop, this shouldn't cause problems.
      Disable if you wish to use alternate applications for the same purpose.
    '' true;
  };

  config = l.mkIf cfg {
    networking.firewall = {
      enable = l.mkDefault true;
      allowedTCPPorts = l.mkDefault [ ];
      allowedUDPPorts = l.mkDefault [ ];
    };
  };
}
