## Why won't my system boot?
Try setting `nix-mineral.settings.kernel.busmaster-bit = false;` since it may
cause boot failure on some hardware.

If you are getting errors about failed mounts, review
[nix-mineral.filesystems.normal](https://cynicsketch.github.io/nix-mineral/options.html#option-nix-mineral.filesystems.normal)
and make sure any directory that is dedicated a specific partition of subvolume
is not bind mounted.

You can see all the mountpoints that are hardened by default here:
https://github.com/cynicsketch/nix-mineral/blob/main/filesystems/normal.nix

## Something isn't working!
Check https://github.com/cynicsketch/nix-mineral/blob/main/presets/compatibility.nix
for any settings that may be relevant to your problem.

## Why does my computer keep randomly rebooting?
You are probably experiencing kernel panics. `nix-mineral.settings.debug.panic-reboot = true;`
automatically reboots the system on panic to prevent information leaks and attempt
to recover the system as fast as possible.

Try setting `nix-mineral.settings.kernel.oops-panic = false;` to see if that makes it
stop, `nix-mineral.settings.debug.panic-reboot = false;` if you'd like to prevent
the reboot, and disable other options in `nix-mineral.settings.debug` for debugging purposes.

If fully disabling `nix-mineral` doesn't fix it, it is likely to be an upstream
problem.
