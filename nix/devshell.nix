# `nix develop` (or direnv): the impure, watch-friendly dev loop.
{ pkgs, rubyEnv, tailwindcss, bundix, system }:
pkgs.mkShell {
  TZDIR = "${pkgs.tzdata}/share/zoneinfo";
  buildInputs = [
    rubyEnv.env
    tailwindcss
    # Regenerates gemset.nix after a Gemfile/Gemfile.lock change.
    bundix.packages.${system}.default
    pkgs.git
  ];
  shellHook = ''
    echo "🚀 Jekyll + Tailwind — Nix dev shell"
    echo ""
    echo "  nix run .#serve      # live dev server (Tailwind --watch + jekyll serve)"
    echo "  nix build .#site     # pure, reproducible build -> ./result"
    echo "  nix run .#preview    # serve the built site via nginx (prod-like URLs)"
    echo "  bundix               # regenerate gemset.nix after a Gemfile change"
  '';
}
