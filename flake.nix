{
  description = "aidenfoxivey.com darwin nixpkg defaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [
          # My shell
          pkgs.fish

          # Apple make is hella out of date
          pkgs.gnumake

          # for linux compatibility, I use gnutar
          pkgs.gnutar

          # big apps
          pkgs.vscode
          pkgs.hexfiend

          pkgs.iina
          pkgs.net-news-wire
          pkgs.spotify

          # apple Git is *usually* out of date
          pkgs.git
          pkgs.git-lfs
          pkgs.git-sizer
          pkgs.git-open

          # C/C++

          # other tools I don't understand
          pkgs.direnv
          pkgs.pkg-config
          pkgs.openssl

          # Golang
          pkgs.gopls
          pkgs.golangci-lint
          pkgs.go

          # Python
          pkgs.python3
          pkgs.ruff
          pkgs.ruff-lsp

          # OCaml
          pkgs.dune_3
          pkgs.ocaml

          # Zig
          pkgs.zig

          # Misc
          pkgs.hyperfine
          pkgs.yt-dlp
          pkgs.mosh
          pkgs._7zz
          pkgs.binwalk
          pkgs.aerc

          # gpg and all that
          pkgs.gnupg
          pkgs.pinentry_mac

          # fonts
          pkgs.jetbrains-mono
          pkgs.iosevka
          pkgs.julia-mono
        ];

      environment.shells = [pkgs.bashInteractive pkgs.zsh pkgs.fish];

      fonts = {
        fontDir.enable = true;
        fonts = with pkgs; [
          iosevka
          fira-mono
        ];
      };
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;
      security.pam.enableSudoTouchIdAuth = true;
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        screencapture.location = "~/Downloads";
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations.orchard = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.orchard.pkgs;
  };
}
