---
title: Building This Site With Nix
layout: post
date: 2026/08/23
description: Producing reproducible builds of this site with Nix
tags: nix software-engineering
author: Aumit Leon
permalink: building-this-site-with-nix
---

I’ve been exploring the magic and utility of reproducible builds with nix for a while now. Nix as a concept just makes sense, and once you get into it, it’s easy to wonder why it isn’t adopted more widely.[^1] Most of my mileage thus far has been focused on nix usages on the development side -- mainly spinning up nix development shells and directory isolated environments. This has been incredibly useful, but I want to begin exploring nix in production (CI/CD, servers, and services). I figure what better place to start than this site! 

[^1]: The learning curve is quite steep, which probably has something to do with it.

# Pre-Nix Architecture 
This site is deployed as a simple [jekyll-github](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll) pages site.[^2] This is a pretty common pattern for personal sites, given the ease of operation, built in version-control, and simple deploys (deploy on merges to `main`). 

[^2]: I’ve gone through a bunch of iterations of jekyll-github pages sites since I first launched my personal site. 

I originally used a tailwind-css template called [tailpages](https://github.com/harrywang/tailpages). The theming was minimalistic and matched my sensibilities at the time. I imagine someday I’ll get tired of it and will have an agent redesign things from scratch. Building the app locally was as simple as installing the ruby dependencies with `gem install --user-install bundler jekyll` and then serving the development server with `bundle exec jekyll serve`. 

# Building the Site with Nix
I was inspired to do this migration after finding Farid Zakaria’s [personal site](https://fzakaria.com/), which also happens to be deployed via Github pages. Outside of being a beautiful site (with even more beautiful writing!), Farid recently modified his site to be completely built via nix. Color me intrigued!

## Dependencies

In order to properly deploy my site via nix, I need to ensure all inputs and dependencies are handled deterministically by nix. My site used tailwind CSS, some static CDN fonts, some ruby dependencies, and a weird dependency on node. To get deterministic builds via nix, I need to make sure that all of these components can be represented in the nix store. 

The ruby dependencies are mainly centered around site building/construction, and migrating those was pretty straight forward. With [bundix](https://github.com/nix-community/bundix), we could easily generate a `gemfile.nix`.[^3] I do development across a mixture of machines and architectures (`aarch64-linux`, `arm64-darwin-24` `x86_64-linux`) so I need my flakes to be functional across all my working surfaces -- luckily, nix makes this super easy, and grabbing the platform specific gems for the `Gemfile.lock` is as simple as running `nix develop -c bundle lock --add-platform <platform>`. 

[^3]: From bundix’s README: the big picture is that bundix tries to fetch a hash for each of your bundle dependencies and store them all together in a format that Nix can understand and is then used by `bundlerEnv`.

 This is the bulk of our dependencies, but I also had to work through a strange dependency on node that was being used with tailwind CSS. Specifically, I previously relied on an awkward yarn/node/PostCSS toolchain to manage the relevant tailwind plugins I was using (`@tailwindcss/typography` which `tailwind.config.js` pulls in, and `autoprefixer`), but the standard `tailwind-cli` is a single binary available as a nix package that packages these first-party plugins.[^4]
 
 
 ```nix
# --- Tailwind CSS 
# The standalone tailwindcss CLI: a single binary that bundles the
# first-party plugins (including @tailwindcss/typography, which
# tailwind.config.js pulls in) and autoprefixer. Replaces the old
# node/yarn/PostCSS toolchain entirely.
tailwindcss = pkgs.tailwindcss;
 ```

[^4]: This migration not only helped me create reproducible builds, it also helped eliminate tech debt! 

## Updating Flake and Scripts
With the dependencies made legible to nix, the last step was to update my flake to include all the relevant commands and build definitions. 

At the start of the flake, we update our inputs:
```nix
inputs = {
	nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
	flake-utils.url = "github:numtide/flake-utils";
	
	# Gems from Gemfile.lock, pinned via gemset.nix (below). ruby-nix builds
	# the gem environment; the inscapist bundix fork regenerates gemset.nix and
	# handles the platform-dependent gems in our lock (ffi, google-protobuf,
	# sass-embedded ship per-platform).
	ruby-nix.url = "github:inscapist/ruby-nix";
	bundix = {
	  url = "github:inscapist/bundix/main";
	  inputs.nixpkgs.follows = "nixpkgs";
	};
};
```

Outside of the standard flake inputs (`nixpkgs` and `flake-utils`), we also include `ruby-nix` and `bundix` to help manage the ruby dependencies. 

### Site Build Derivation
The following is the derivation that helps build the site. I give it specific inputs for the build, and specify relevant build and install phases. 
```nix
 # --- The built site: `nix build` 
site = pkgs.stdenv.mkDerivation {
  # Bare `name` (no version) so the store path ends in `aumitleon.dev`.
  name = "aumitleon.dev";

  # Explicit rather than `fileset.gitTracked` because that reads .git,
  # which the flake's source copy in the store does not carry. Lists the
  # inputs Jekyll (and the Tailwind pass) actually read.
  src = fs.toSource {
    root = ./.;
    fileset = fs.unions [
      ./_config.yml
      ./_layouts
      ./_includes
      ./_plugins
      ./_posts
      ./_styles
      ./assets
      ./legacy
      ./tailwind.config.js
      ./404.html
      ./CNAME
      ./about.md
      ./blog.md
      ./index.md
      ./projects.md
      ./tag.md
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
};
```

## Deploys

To deploy, I had to switch from auto-deploying on pushes to `main`, and instead, deploy via Github actions. I setup a new workflow that executed my build and then ran the deploy. These are the job definitions for my workflow: 

```yaml
jobs:
  # Build the site with Nix. The flake pins Ruby/Jekyll (via gemset.nix) and
  # Tailwind (the standalone tailwindcss CLI), so this is the exact same build
  # that `nix build .#site` runs locally -- no separate Ruby/Node setup.
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main

      # A clean checkout means self.rev resolves to this commit, so the footer's
      # "Improve this page" link and Nix store path point at the exact deployed
      # revision. Most of the toolchain comes from cache.nixos.org; only the
      # gems and the site itself build here.
      - name: Build site
        run: nix build .#site --print-build-logs

      - name: Prepare artifact
        run: |
          mkdir -p _site
          cp -rL result/. _site/
          chmod -R u+w _site

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  # Publish the built artifact to GitHub Pages.
  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

The Github actions for the nix build are not currently leveraging any type of specific binary cache (like [cachix](https://www.cachix.org/) or [attic](https://github.com/zhaofengli/attic), etc),[^5] but they are still pretty snappy given the site is quite small (complete in less than 2 minutes). 

[^5]: Yet.

<center>
<figure>
  <img src="assets/img/blog_img/nix_build_github_action.png" />
  <figcaption>Github action invocation for the site’s nix build and deploy.</figcaption>
</figure>
</center>


One more fun tidbit, again, inspired by Farid’s site, I added the nix store path to the site’s footer. 

<center>
<figure>
  <img src="assets/img/blog_img/nix_store_path_in_site.png" />
  <figcaption>The site’s footer.</figcaption>
</figure>
</center>

Nix store paths are input addressable, which includes the platform on which the build happened. Github actions runs on x86_64 machines, so while the nix store path won’t match on my Mac (which is an aarm64 machine), it exactly matches when I build and spin up the site from my x86_64 machine -- a fun way to confirm and prove the reproducibility we get with nix! 

<center>
<figure>
  <img src="assets/img/blog_img/nix_store_derivation.png" />
  <figcaption>The site’s footer.</figcaption>
</figure>
</center>

# Closing Thoughts and Agentic Development 
This migration, like many other side projects that long sat collecting dust, was made feasible by how strong LLMs and agents have gotten at understanding and generating quality code. I was able to make this entire migration in under an hour, with some prodding and guidance. Reproducible builds are more important than ever as we produce more software than ever. Ensuring that agents (locally, in sandboxes, and in production) are always working with deterministically reproducible builds makes it easy to build higher quality software that obviates entire classes of software development issues. 
