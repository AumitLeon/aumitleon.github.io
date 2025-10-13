# aumitleon.github.io
Portfolio

Visit: https://aumitleon.dev/

Built with tailpages: https://github.com/harrywang/tailpages 

# Development

## Using Nix Flake (Recommended)

If you have Nix with flakes enabled, you can use the provided flake for a consistent development environment:

```bash
# Enter the development shell
nix develop

# Or use the provided commands directly:
nix run .#install    # Install all dependencies (Ruby gems + Node packages)
nix run .#serve      # Start development server
nix run .#build      # Build the site
```

## Manual Setup

### Install depedencies
```
gem install --user-install bundler jekyll
```

### Build
```
bundle exec jekyll serve
```