{
  description = "aumitleon.github.io — Jekyll + Tailwind CSS, built with Nix";

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

  outputs = { self, nixpkgs, flake-utils, ruby-nix, bundix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Each concern lives in its own module under ./nix. They are plain
        # functions: this `let` passes each exactly the dependencies it needs,
        # so the call sites double as a dependency graph.
        rubyEnv = import ./nix/ruby.nix { inherit pkgs ruby-nix; };
        tailwind = import ./nix/tailwind.nix { inherit pkgs; };
        inherit (tailwind) tailwindcss tailwindBuild;

        site = import ./nix/site.nix {
          inherit pkgs self rubyEnv tailwindcss tailwindBuild;
        };
        preview = import ./nix/preview.nix { inherit pkgs site; };

        siteApps = import ./nix/apps.nix {
          inherit pkgs rubyEnv tailwindcss preview;
        };
        devShell = import ./nix/devshell.nix {
          inherit pkgs rubyEnv tailwindcss bundix system;
        };
      in
      {
        packages = {
          default = site;
          site = site;
        };

        devShells.default = devShell;

        apps = {
          inherit (siteApps) serve preview;
        };
      });
}
