{
  l,
  cfg,
  ...
}:

{
  options = {
    tcp-window-scaling = l.mkBoolOption ''
      Disable TCP window scaling.
      if false, may help mitigate TCP reset DoS attacks, but
      may also harm network performance when at high latencies.
    '' true;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl."net.ipv4.tcp_window_scaling" = l.mkForce "0";
  };
}
