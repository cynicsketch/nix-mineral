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
      Disable kernel modules related to firewire, as it uses DMA which could be
      used in a DMA attack.

      ::: {.note}
      See:
        - https://en.wikipedia.org/wiki/DMA_attack
        - https://eclypsium.com/research/direct-memory-access-attacks-a-walk-down-memory-lane/
        - https://emb3d.mitre.org/threats/TID-107.html

      This option disables kernel modules from the
      [secureblue kernel modules list](https://github.com/${ssb.user}/${ssb.repo}/blob/${ssb.rev}/${ssb.file}#L36-L54).
      This excludes the modules: `thunderbolt` and `thunderbolt_net`.
      :::
    '';
    modules = (mkSBKModulesList 36 43) ++ (mkSBKModulesList 47 55);
    default = true;
  };

  thunderbolt-related = {
    description = ''
      Disable kernel modules related to thunderbolt, as it uses DMA which
      could be abused in a DMA attack.

      ::: {.note}
      See:
        - https://en.wikipedia.org/wiki/DMA_attack
        - https://eclypsium.com/research/direct-memory-access-attacks-a-walk-down-memory-lane/
        - https://emb3d.mitre.org/threats/TID-107.html
      :::

      ::: {.note}
      Thunderbolt may be necessary for proper suspend function on modern laptops.
      If thunderbolt is not enabled, suspend may consume abnormal amounts of power.

      See:
      https://github.com/secureblue/secureblue/issues/2437
      :::
    '';
    modules = (mkSBKModulesList 44 46);
    default = true;
  };

  unused-filesystems = mkSBKModulesOption 57 117 "commonly unused filesystems" { };

  gnss-related = mkSBKModulesOption 120 126 "GNSS" { };

  cdrom-related = mkSBKModulesOption 139 141 "cdrom" { };

  esp4-and-esp6 = mkSBKModulesOption 147 151 ''
    esp4 and esp6.
    They provide support for Encapsulating Security Payload, part of IPSec
  '' { };

  ipsec-vti = mkSBKModulesOption 153 157 "IPSEC Virtual Tunnel Interface (VTI)" { };

  xfrm-related =
    mkSBKModulesOption 159 167 "xfrm, another part of IPSec involved in related exploits"
      { };

  ipsec-related = mkSBKModulesOption 169 174 "IPSec" { };

  l2tp-related = mkSBKModulesOption 176 184 "l2tp (depends on IPSec)" { };

  legacy-interfaces = mkSBKModulesOption 189 203 "legacy interfaces" { };

  kernel-debugging-related = mkSBKModulesOption 207 259 "kernel debugging/development" { };

  automotive-related = mkSBKModulesOption 261 301 "automotive/industrial" { };

  rdma-related = mkSBKModulesOption 304 319 "[RDMA](https://wiki.debian.org/RDMA)" { };

  gpib-related = mkSBKModulesOption 322 345 "[GPIB](https://en.wikipedia.org/wiki/GPIB)" { };

  dvb-and-tv-receivers = mkSBKModulesOption 348 663 "DVB and TV receivers" { };

  joystick-drivers = mkSBKModulesOption 666 732 "joystick drivers" { };

  remote-controls = mkSBKModulesOption 735 909 "remote controls" { };

  legacy-digital-cameras = mkSBKModulesOption 912 965 ''
    legacy digital cameras (pre-2010).
    This often refers to point-and-shoot digital cameras predating USB webcams,
    e.g. Kodak EZ200, Fujifilm FinePix F402, etc.
  '' { };

  radio-tuners = mkSBKModulesOption 971 986 "radio tuners" { };

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
