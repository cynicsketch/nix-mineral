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

        Note about disabling all CPU mitigations:
        Turning all CPU mitigations off completely is a terrible idea. Even the most robustly sandboxed
        and restricted code in the world can instantly rootkit your computer.
        One web page is all it takes for all your keys to be someone else's: https://leaky.page/
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
