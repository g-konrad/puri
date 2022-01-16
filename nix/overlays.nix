{ sources, compiler }:
[
  (final: prev: {
    inherit (import sources.gitignore { inherit (prev) lib; }) gitignoreFilter;
  })
  (final: prev: {
    puri = import ./packages.nix { pkgs = prev; inherit compiler; };
  })
]
