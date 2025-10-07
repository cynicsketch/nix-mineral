{
  l,
  cfg,
  pkgs,
  config,
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
      (writeShellScriptBin "sudo" ''
        exec ${config.security.wrapperDir}/doas "$@"
      '')
      (writeShellScriptBin "sudoedit" ''
        exec ${config.security.wrapperDir}/doas ${l.getExe' nano "rnano"} "$@"
      '')
      (writeShellScriptBin "doasedit" ''
        exec ${config.security.wrapperDir}/doas ${l.getExe' nano "rnano"} "$@"
      '')
    ];
  };
}
