.PHONY: serve preview build shell bundix dev push-cachix help

CACHIX_CACHE ?= aumitleon

# Default target
help:
	@echo "🚀 Jekyll + Tailwind CSS — Nix workflow"
	@echo ""
	@echo "Available commands:"
	@echo "  make serve   - Live dev server (Tailwind --watch + jekyll serve)"
	@echo "  make preview - Serve the built site via nginx (prod-like URLs) on :8080"
	@echo "  make build   - Pure, reproducible build -> ./result"
	@echo "  make shell   - Enter the Nix dev shell"
	@echo "  make bundix  - Regenerate gemset.nix after a Gemfile change"
	@echo "  make dev     - Alias for serve"
	@echo "  make push-cachix - Push the build closure (gems + site) to the Cachix cache"
	@echo "  make help    - Show this help message"
	@echo ""

# Live development server
serve:
	nix run .#serve

# Serve the built site via nginx with production-like URL handling
preview:
	nix run .#preview

# Pure, reproducible build (output symlinked at ./result)
build:
	nix build .#site

# Interactive development shell
shell:
	nix develop

# Regenerate gemset.nix from Gemfile.lock (run after changing the Gemfile)
bundix:
	nix develop -c bundix

# Alias for serve
dev: serve

# Push the full build closure (gems, Ruby, and the site output) to Cachix.
# Builds first so the closure is current, then pushes every output path not
# already in the cache. Mirrors what CI's cachix-action uploads. Requires a
# write-authed cachix CLI (`cachix authtoken <token>`). Override the cache with
# `make push-cachix CACHIX_CACHE=othername`.
push-cachix: build
	nix-store -qR --include-outputs $$(nix path-info --derivation .#site) \
		| grep -v '\.drv$$' \
		| cachix push $(CACHIX_CACHE)
