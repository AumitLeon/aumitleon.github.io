# --- Tailwind CSS --------------------------------------------------------
# The standalone tailwindcss CLI: a single binary that bundles the
# first-party plugins (including @tailwindcss/typography, which
# tailwind.config.js pulls in) and autoprefixer. Replaces the old
# node/yarn/PostCSS toolchain entirely.
{ pkgs }:
let
  tailwindcss = pkgs.tailwindcss;

  # Compile _styles/main.css -> the served stylesheet. Shared verbatim by
  # the build below and the dev workflow so both emit identical CSS.
  # Scans ./**/*.html (per tailwind.config.js `content`); run after
  # `jekyll build` it also sees the rendered pages under _site, so every
  # utility class actually used on the site is captured.
  tailwindBuild = out: ''
    ${tailwindcss}/bin/tailwindcss \
      --config ./tailwind.config.js \
      --input ./_styles/main.css \
      --output ${out} \
      --minify
  '';
in
{ inherit tailwindcss tailwindBuild; }
