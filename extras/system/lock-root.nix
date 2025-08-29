{
  l,
  cfg,
  ...
}:

{
  options = {
    lock-root = l.mkBoolOption ''
      Lock the root account. Requires another method of privilege escalation, i.e
      sudo or doas, and declarative accounts to work properly.
    '' false;
  };

  config = l.mkIf cfg {
    users.users.root.hashedPassword = l.mkDefault "!";
  };
}
