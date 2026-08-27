# --- The built site: `nix build` -----------------------------------------
{ pkgs, self, rubyEnv, tailwindcss, tailwindBuild }:
let
  fs = pkgs.lib.fileset;
in
pkgs.stdenv.mkDerivation {
  # Bare `name` (no version) so the store path ends in `aumitleon.dev`.
  name = "aumitleon.dev";

  # Explicit rather than `fileset.gitTracked` because that reads .git,
  # which the flake's source copy in the store does not carry. Lists the
  # inputs Jekyll (and the Tailwind pass) actually read.
  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../_config.yml
      ../_layouts
      ../_includes
      ../_plugins
      ../_posts
      ../_styles
      ../assets
      ../legacy
      ../tailwind.config.js
      ../404.html
      ../CNAME
      ../about.md
      ../blog.md
      ../index.md
      ../projects.md
      ../tag.md
    ];
  };

  nativeBuildInputs = [ rubyEnv.env tailwindcss ];

  env = {
    JEKYLL_ENV = "production";
    # The sandbox ships no locale; without this Ruby tags subprocess
    # output as US-ASCII and the first multibyte char raises.
    LANG = "C.UTF-8";
    # The sandbox has no /etc/zoneinfo, so `timezone:` in _config.yml
    # would silently resolve to UTC.
    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    # _plugins/commit_hash.rb reads GITHUB_SHA for the footer's
    # "Improve this page" link. No .git in the sandbox, so the flake
    # supplies the revision it was built from: the commit when clean,
    # "<sha>-dirty" when the tree has uncommitted changes.
    GITHUB_SHA = self.rev or self.dirtyRev or "dirty";
    # _plugins/nix_store.rb surfaces this in the footer as the store path
    # the site was built into. `placeholder "out"` is rewritten to the
    # real $out in the build environment before jekyll runs, so the page
    # names its own store path without the hash being circular.
    JEKYLL_STORE_PATH = builtins.placeholder "out";
  };

  buildPhase = ''
    runHook preBuild
    jekyll build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r _site/. $out/
    mkdir -p $out/assets/css
    ${tailwindBuild "$out/assets/css/style.css"}
    runHook postInstall
  '';
}
