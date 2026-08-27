# Runnable entry points: `nix run .#serve` and `nix run .#preview`.
{ pkgs, rubyEnv, tailwindcss, preview }:
{
  # `nix run .#serve`: compile CSS on change and serve a live Jekyll build.
  serve = {
    type = "app";
    program =
      let
        serve = pkgs.writeShellScriptBin "serve" ''
          set -e
          export TZDIR="${pkgs.tzdata}/share/zoneinfo"
          # Compile once up front so the stylesheet exists before Jekyll's
          # first build -- otherwise the initial requests 404 on style.css
          # in the gap before the watcher's first pass finishes.
          echo "🎨 Compiling Tailwind CSS -> assets/css/style.css"
          ${tailwindcss}/bin/tailwindcss \
            --config ./tailwind.config.js \
            --input ./_styles/main.css \
            --output ./assets/css/style.css \
            --minify
          echo "🎨 Watching Tailwind CSS for changes"
          ${tailwindcss}/bin/tailwindcss \
            --config ./tailwind.config.js \
            --input ./_styles/main.css \
            --output ./assets/css/style.css \
            --minify --watch &
          tailwind_pid=$!
          trap "kill $tailwind_pid 2>/dev/null || true" EXIT
          exec ${rubyEnv.env}/bin/jekyll serve --host 0.0.0.0 "$@"
        '';
      in
      "${serve}/bin/serve";
  };

  # `nix run .#preview`: build the site and serve it behind nginx, with the
  # production `/about` -> about.html URL handling.
  preview = {
    type = "app";
    program = "${preview}/bin/preview";
  };
}
