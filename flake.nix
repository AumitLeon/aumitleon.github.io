{
  description = "Jekyll blog with Tailwind CSS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Ruby environment with bundler
        rubyEnv = pkgs.ruby_3_3;

        # Node environment
        nodejs = pkgs.nodejs_20;
        yarn = pkgs.yarn;

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rubyEnv
            pkgs.bundler
            nodejs
            yarn
            pkgs.git
          ];

          # Keep system packages available
          shellHook = ''
            export PATH="$PATH"

            echo "🚀 Jekyll + Tailwind CSS development environment"
            echo ""
            echo "Available commands:"
            echo "  nix run .#install    - Install all dependencies (Ruby gems + Node packages)"
            echo "  nix run .#serve      - Start development server"
            echo "  nix run .#build      - Build the site"
            echo ""
            echo "Or run manually:"
            echo "  bundle install       - Install Ruby dependencies"
            echo "  yarn install         - Install Node dependencies"
            echo "  bundle exec jekyll serve - Start Jekyll server"
            echo ""
            echo "✓ System packages remain available"
          '';
        };

        packages = {
          # Install all dependencies
          install = pkgs.writeShellScriptBin "install" ''
            export GEM_HOME="$(pwd)/.gems"
            export PATH="$GEM_HOME/bin:$PATH"

            echo "📦 Installing Ruby dependencies..."
            ${pkgs.bundler}/bin/bundle install --path .gems

            echo "📦 Installing Node dependencies..."
            ${yarn}/bin/yarn install

            echo "✅ All dependencies installed!"
          '';

          # Start development server
          serve = pkgs.writeShellScriptBin "serve" ''
            export GEM_HOME="$(pwd)/.gems"
            export PATH="$GEM_HOME/bin:$PATH"

            echo "🌐 Starting Jekyll development server..."
            ${pkgs.bundler}/bin/bundle exec jekyll serve
          '';

          # Build the site
          build = pkgs.writeShellScriptBin "build" ''
            export GEM_HOME="$(pwd)/.gems"
            export PATH="$GEM_HOME/bin:$PATH"

            echo "🔨 Building Jekyll site..."
            ${pkgs.bundler}/bin/bundle exec jekyll build
            echo "✅ Build complete! Output in _site/"
          '';
        };

        apps = {
          install = {
            type = "app";
            program = "${self.packages.${system}.install}/bin/install";
          };

          serve = {
            type = "app";
            program = "${self.packages.${system}.serve}/bin/serve";
          };

          build = {
            type = "app";
            program = "${self.packages.${system}.build}/bin/build";
          };
        };

        # Default app
        defaultApp = self.apps.${system}.serve;
      }
    );
}
