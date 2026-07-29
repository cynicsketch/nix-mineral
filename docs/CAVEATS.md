# The state of Desktop Linux Security
Excluding ChromeOS and Android, the default Linux security model is very poor.

https://madaidans-insecurities.github.io/linux.html \
https://privsec.dev/posts/linux/linux-insecurities/

A large portion of problems are related to bad privilege separation because all
processes started by a user always inherit all of said user's privileges, except
when a policy is explicitly defined against it.

`nix-mineral` can't fix this, because resolving it is entirely dependent on the
individual nuance of the software running on a user's system and not practical
to heuristically contain in any meaningful way without foreknowledge of said
software.

# Unique problems of NixOS
Normally, MAC policies (though often incomplete) provide at least a theoretical
means to confine system applications to some degree.

However, NixOS still does not have a functional Mandatory Access Control (MAC)
framework with policies that work with the nix store, since existing policies
all assume [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)
compliance. This is a **major** security degradation compared to Linux distributions
such as Fedora which [uses SELinux by default](https://docs.fedoraproject.org/en-US/quick-docs/selinux-getting-started/)
and [confines a large number of applications](https://github.com/fedora-selinux/selinux-policy).

https://github.com/NixOS/nixpkgs/issues/347490 \
https://github.com/NixOS/nixpkgs/issues/169056 \
https://hedgedoc.grimmauld.de/s/03eJUe0X3#

# Default deny is impossible to implement
So-called "badness enumeration" is functionally incomplete and inevitably results
in a huge amount of attack surface left unchecked.

https://privsec.dev/posts/knowledge/badness-enumeration/ \
https://www.ranum.com/security/computer_security/editorials/dumb/

While implementing a default deny policy for as many things as possible is one
of the best things one can do to limit attack surface, `nix-mineral` can't do
this because it's fundamentally context unaware and has to play nice
with the fact that the systems it is deployed on will be hugely variable in
function. It is not possible to implement without a significant degree of user
input which would defeat the point of creating an abstraction.

# Why bother with nix-mineral then?
For all things security related, risk tolerance must be considered.

`nix-mineral` is for people who, in spite of everything else, choose to use
NixOS anyways for its benefits and accept the tradeoffs that entails.

For individuals who want to use Linux but prioritize security more heavily
and are ambivalent towards the use of the nix programming language, secureblue
(https://secureblue.dev/) provides significantly better overall security as a
complete Linux distribution, although still limited by upstream factors.
