{
  l,
  cfg,
  ...
}:

{
  options = {
    tcp-timestamps = l.mkBoolOption ''
      Enables tcp_timestamps.
      Disabling prevents leaking system time, enabling protects against
      wrapped sequence numbers and improves performance.

      Read more about the issue here:
      URL: (In favor of disabling): https://madaidans-insecurities.github.io/guides/linux-hardening.html#tcp-timestamps
      URL: (In favor of enabling): https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
    '' true;
  };

  config = l.mkIf cfg {
    boot.kernel.sysctl = {
      "net.ipv4.tcp_timestamps" = l.mkDefault "1";
    };
  };
}
