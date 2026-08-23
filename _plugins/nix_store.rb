# frozen_string_literal: true

# Expose the Nix store path this site was built into as `site.nix_store_path`.
#
# The flake's site derivation exports JEKYLL_STORE_PATH=$out before running
# `jekyll build`, so the pages can name the /nix/store/... path they live in --
# the footer renders it as a small "built by Nix" badge. A plain `jekyll build`
# or `jekyll serve` (dev) leaves the variable unset, so the footer line simply
# doesn't appear off the Nix build.
#
# Runs only under a full (non-safe) Jekyll build, same as the other _plugins.
Jekyll::Hooks.register :site, :after_init do |site|
  path = ENV["JEKYLL_STORE_PATH"]
  site.config["nix_store_path"] = path unless path.nil? || path.empty?
end
