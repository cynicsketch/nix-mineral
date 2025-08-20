{
  l,
  cfg,
  ...
}:

{
  options = {
    unprivileged-userns = l.mkBoolOption ''
      Enable unprivileged user namespaces, is a large attack surface
      and has been the cause of many privilege escalation vulnerabilities,
      but can cause breakage. It is used in the Chromium sandbox, unprivileged containers,
      and bubblewrap among many other applications.
      if false, this may break some applications that rely on user namespaces.
    '' false;
  };

  config = l.mkIf (!cfg) {
    boot.kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = l.mkDefault "0";
    };
  };
}
