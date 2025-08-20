{
  l,
  cfg,
  ...
}:

{
  options = {
    cpu-mitigations = l.mkOption {
      description = ''
        Apply relevant CPU exploit mitigations, May harm performance.

        `smt-off` - Enable CPU mitigations and disables symmetric multithreading.
        `smt-on` - Enable symmetric multithreading and just use default CPU mitigations,
        to potentially improve performance.
        `off` - Disables all CPU mitigations. May improve performance further,
        but is even more dangerous!
      '';
      default = "smt-off";
      type = l.types.enum [
        "smt-off"
        "smt-on"
        "off"
      ];
    };
  };

  config = {
    boot.kernelParams = [
      "${
        if (cfg == "smt-off") then
          "mitigations=auto,nosmt"
        else if (cfg == "smt-on") then
          "mitigations=auto"
        else
          "mitigations=off"
      }"
    ];
  };
}
