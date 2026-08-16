{
  l,
}:

let
  secureblueKModulesFile = l.readFile (l.fetchGhFile l.sources.secureblue-disabled-kernel-modules);
  # Takes a starting line number and an ending line number from the secureblue kernel modules list,
  # searches for all modules in that range (excluding comments) and returns them as a list of strings.
  mkSBKModulesList =
    first: last:
    let
      # It might seem strange to use `map` with a `range` in this situation,
      # but using `drop` and `take` ends up being less performant.
      lines = l.map (
        lineNumber: l.trim (l.elemAt (l.splitString "\n" secureblueKModulesFile) lineNumber)
      ) (l.range (first - 1) (last - 1));
    in
    l.map (module: l.trim (l.removeSuffix "/bin/false" (l.removePrefix "install" module))) (
      l.filter (line: l.hasPrefix "install " line) lines
    );
  ssb = l.sources.secureblue-disabled-kernel-modules;
  # Helper function to create the option with the list of modules, a default value of true,
  # and a description that includes a link to the exact lines in the secureblue kernel modules list.
  mkSBKModulesOption =
    first: last: description: extraOptions:
    {
      description = ''
        Disable kernel modules related to ${l.trim description}.

        ::: {.note}
        This option disables kernel modules from the
        [secureblue kernel modules list](https://github.com/${ssb.user}/${ssb.repo}/blob/${ssb.rev}/${ssb.file}#L${toString first}-L${toString last}).
        :::
      '';
      modules = mkSBKModulesList first last;
      default = true;
    }
    // extraOptions;
in
{
  unused-network-protocols = mkSBKModulesOption 1 34 "commonly unused network protocols" { };

  firewire-related = {
    description = ''
      Disable kernel modules related to firewire.

      ::: {.note}
      This option disables kernel modules from the
      [secureblue kernel modules list](https://github.com/${ssb.user}/${ssb.repo}/blob/${ssb.rev}/${ssb.file}#L36-L54).
      This excludes the modules: `thunderbolt` and `thunderbolt_net`.
      :::
    '';
    modules = (mkSBKModulesList 36 43) ++ (mkSBKModulesList 46 54);
    default = true;
  };

  thunderbolt-related = mkSBKModulesOption 44 45 "thunderbolt" { };

  unused-filesystems = mkSBKModulesOption 56 116 "commonly unused filesystems" { };

  gnss-related = mkSBKModulesOption 119 125 "GNSS" { };

  cdrom-related = mkSBKModulesOption 139 140 "cdrom" { };

  esp4-and-esp6 = mkSBKModulesOption 146 150 ''
    esp4 and esp6.
    They provide support for Encapsulating Security Payload, part of IPSec
  '' { };

  xfrm-related =
    mkSBKModulesOption 152 160 "xfrm, another part of IPSec involved in related exploits"
      { };

  ipsec-related = mkSBKModulesOption 162 167 "IPSec" { };

  l2tp-related = mkSBKModulesOption 169 177 "l2tp (depends on IPSec)" { };

  legacy-interfaces = mkSBKModulesOption 182 196 "legacy interfaces" { };

  kernel-debugging-related = mkSBKModulesOption 200 252 "kernel debugging/development" { };

  automotive-related = mkSBKModulesOption 254 294 "automotive/industrial" { };

  rdma-related = mkSBKModulesOption 297 312 "[RDMA](https://wiki.debian.org/RDMA)" { };

  gpib-related = mkSBKModulesOption 315 338 "[GPIB](https://en.wikipedia.org/wiki/GPIB)" { };

  dvb-and-tv-receivers = mkSBKModulesOption 341 656 "DVB and TV receivers" { };

  joystick-drivers = mkSBKModulesOption 659 725 "joystick drivers" { };

  remote-controls = mkSBKModulesOption 728 902 "remote controls" { };

  legacy-digital-cameras = mkSBKModulesOption 905 958 ''
    legacy digital cameras (pre-2010).
    This often refers to point-and-shoot digital cameras predating USB webcams,
    e.g. Kodak EZ200, Fujifilm FinePix F402, etc.
  '' { };

  radio-tuners = mkSBKModulesOption 961 976 "radio tuners" { };

  secureblue-additional = {
    default = true;
    description = ''
      Disable additional kernel modules from the secureblue kernel modules list
      that are not covered by other options.

      ::: {.note}
      This option disables kernel modules from the secureblue kernel modules list:
      - [ath_pci](https://github.com/secureblue/secureblue/blob/895568699c341167a53b106bd08a8ed973734aaa/files/system/usr/lib/modprobe.d/secureblue.conf#L132)
      - [x86-android-tablets](https://github.com/secureblue/secureblue/blob/895568699c341167a53b106bd08a8ed973734aaa/files/system/usr/lib/modprobe.d/secureblue.conf#L136)
      - [rxrpc](https://github.com/secureblue/secureblue/blob/895568699c341167a53b106bd08a8ed973734aaa/files/system/usr/lib/modprobe.d/secureblue.conf#L144)
      - [sunrpc](https://github.com/secureblue/secureblue/blob/895568699c341167a53b106bd08a8ed973734aaa/files/system/usr/lib/modprobe.d/secureblue.conf#L180)
      - [floppy](https://github.com/secureblue/secureblue/blob/895568699c341167a53b106bd08a8ed973734aaa/files/system/usr/lib/modprobe.d/secureblue.conf#L198)
      :::
    '';
    modules = [
      # block loading ath_pci
      "ath_pci"
      # X86 android tablet support
      "x86-android-tablets"
      # dirtyfrag mitigation: https://github.com/V4bel/dirtyfrag#mitigation
      # RxRPC network protocol: https://www.kernel.org/doc/html/latest/networking/rxrpc.html
      "rxrpc"
      # disable Sun RPC: https://en.wikipedia.org/wiki/Sun_RPC
      "sunrpc"
      # https://en.wikipedia.org/wiki/Floppy_disk
      "floppy"
    ];
  };
}
