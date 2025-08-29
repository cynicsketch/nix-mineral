{
  l,
  cfg,
  pkgs,
  ...
}:

{
  options = {
    doas-sudo-wrapper = l.mkBoolOption ''
      Creates a wrapper for doas to simulate sudo, with nano to utilize rnano as
      editor for editing as root.
    '' false;
  };

  config = l.mkIf cfg {
    environment.systemPackages = with pkgs; [
      (writeScriptBin "sudo" ''exec ${l.getExe doas} "$@"'')
      (writeScriptBin "sudoedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
      (writeScriptBin "doasedit" ''exec ${l.getExe doas} ${l.getExe' nano "rnano"} "$@"'')
    ];
  };
}
