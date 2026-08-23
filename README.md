# aumitleon.github.io

Portfolio & blog. Visit: https://aumitleon.dev/

Originally scaffolded from [tailpages](https://github.com/harrywang/tailpages);
it's a [Jekyll](https://jekyllrb.com/) site styled with [Tailwind CSS](https://tailwindcss.com/),
now built entirely with [Nix](https://nixos.org/).

## Quick start

With Nix (flakes enabled) — nothing else needs to be installed on the host:

```bash
make serve      # live dev server at http://localhost:4000
make preview    # serve the real Nix build at http://localhost:8080
make build      # produce the site at ./result
```

Run `make help` to list every command.

## How this repo builds with Nix

Everything is wired through [`flake.nix`](./flake.nix). The goal is a single,
reproducible build that runs the same way locally and in CI — no "works on my
machine" gaps between Ruby versions, gem sets, or a Tailwind install.

- **Ruby & Jekyll** are pinned by [`gemset.nix`](./gemset.nix), generated from
  `Gemfile.lock` by [`bundix`](https://github.com/inscapist/bundix) and turned
  into a gem environment by [`ruby-nix`](https://github.com/inscapist/ruby-nix).
  No system Ruby or `bundle install` is involved.
- **Tailwind CSS** is compiled by the standalone `tailwindcss` CLI from
  `nixpkgs` — a single binary that bundles the first-party plugins (including
  `@tailwindcss/typography`) and autoprefixer. There is **no Node/npm/yarn** in
  the build.
- **The site** is a normal Nix derivation (`packages.site`): it runs
  `jekyll build`, then compiles `_styles/main.css` into
  `assets/css/style.css`, and outputs the finished `_site` to the Nix store.
- **The build is pinned and sandboxed** — all inputs are fixed by `flake.lock`
  and `gemset.nix`, nothing is fetched at build time, and the same source
  produces the same output.

`nix build .#site` (or `make build`) drops a `./result` symlink pointing at the
store path, e.g. `/nix/store/<hash>-aumitleon.dev`. That store path is also shown
in the site footer (see below).

### Two small build-time plugins

- [`_plugins/commit_hash.rb`](./_plugins/commit_hash.rb) — exposes the build's
  git commit as `site.commit_hash` for the footer's "Improve this page" link.
- [`_plugins/nix_store.rb`](./_plugins/nix_store.rb) — exposes the `/nix/store/…`
  path the site was built into as `site.nix_store_path`, rendered as a small
  "built by Nix" badge in the footer. It only appears on the Nix build (the
  flake exports `JEKYLL_STORE_PATH`); a plain `jekyll serve` omits it.

## Commands

All commands are thin wrappers in the [`Makefile`](./Makefile) over the flake:

| Command        | What it does                                                                 |
| -------------- | --------------------------------------------------------------------------- |
| `make serve`   | Live dev server — runs `tailwindcss --watch` alongside `jekyll serve` at http://localhost:4000. Fast iteration; omits the store-path badge. |
| `make preview` | Serves the actual Nix build behind nginx at http://localhost:8080, with the same `try_files $uri $uri.html` URL handling GitHub Pages uses (so `/about` resolves). This is exactly what deploys. |
| `make build`   | Pure, reproducible build → `./result` (the finished `_site`).                |
| `make shell`   | Enters the Nix dev shell (`nix develop`) with Ruby, Jekyll, Tailwind, and bundix on `PATH`. |
| `make bundix`  | Regenerates `gemset.nix` from `Gemfile.lock` after a gem change.             |
| `make dev`     | Alias for `make serve`.                                                      |
| `make help`    | Lists the available commands.                                               |

Equivalent flake invocations: `nix run .#serve`, `nix run .#preview`,
`nix build .#site`, `nix develop`.

## Making changes

- **Content:** add posts under `_posts/`, edit pages (`about.md`, `index.md`, …)
  and templates in `_layouts/` / `_includes/`. `make serve` live-reloads.
- **Styles:** `_styles/main.css` is the Tailwind **input** (`@tailwind`
  directives + custom CSS). The compiled stylesheet is written to
  `assets/css/style.css`, which is git-ignored and regenerated on every
  build/serve — don't edit it by hand. Tailwind's scanned content is configured
  in [`tailwind.config.js`](./tailwind.config.js).
- **Ruby gems:** edit the `Gemfile`, refresh `Gemfile.lock`, then run
  `make bundix` to regenerate `gemset.nix`, and commit all three.

## Deployment

[`.github/workflows/deploy.yml`](./.github/workflows/deploy.yml) builds the site
with `nix build .#site` on pushes to `main` and publishes the result to GitHub
Pages. Because CI uses the same flake, the deployed site is byte-for-byte what
`make build` produces locally. A clean commit means the footer's git hash and
store path reflect the exact deployed revision.

## Manual setup (without Nix)

Not recommended — you lose reproducibility — but possible:

```bash
gem install --user-install bundler jekyll
bundle exec jekyll serve
# and compile the stylesheet yourself:
tailwindcss -c tailwind.config.js -i _styles/main.css -o assets/css/style.css --minify
```
