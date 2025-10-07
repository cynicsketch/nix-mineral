{
  l,
  cfg,
  ...
}:

{
  options = {
    yama = l.mkOption {
      description = ''
        Yama restricts ptrace, which allows processes to read and modify the
        memory of other processes. This has obvious security implications.

        `none` - Keep the default configuration of your kernel.
        `relaxed` - Only allow parent processes to ptrace child processes.
        `restricted` - No processes may be traced with ptrace.
      '';
      default = "relaxed";
      type = l.types.enum [
        "none"
        "relaxed"
        "restricted"
      ];
    };
  };

  config = l.mkIf (cfg != "none") {
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = l.mkForce (if cfg == "relaxed" then "1" else "3");
  };
}
