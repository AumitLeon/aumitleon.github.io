.PHONY: install serve build dev help

# Default target
help:
	@echo "🚀 Jekyll + Tailwind CSS development environment"
	@echo ""
	@echo "Available commands:"
	@echo "  make install    - Install all dependencies (Ruby gems + Node packages)"
	@echo "  make serve      - Start development server"
	@echo "  make build      - Build the site"
	@echo "  make dev        - Alias for serve"
	@echo "  make help       - Show this help message"
	@echo ""

# Install all dependencies
install:
	nix run .#install

# Start development server
serve:
	nix run .#serve

# Build the site
build:
	nix run .#build

# Alias for serve
dev: serve