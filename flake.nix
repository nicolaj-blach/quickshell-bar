{
  description = "QuickShell Top Bar - TUI-style status bar for Niri";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      quickshell,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      quickshellPkg = quickshell.packages.${system}.default;

      topBar = pkgs.stdenv.mkDerivation {
        pname = "quickshell-bar";
        version = "0.1.0";

        src = ./.;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          mkdir -p $out/share/quickshell-bar
          mkdir -p $out/bin

          # Copy QML files
          cp -r *.qml $out/share/quickshell-bar/
          cp -r widgets $out/share/quickshell-bar/

          # Create wrapper script
          cat > $out/bin/quickshell-bar << 'EOF'
          #!/usr/bin/env bash
          exec quickshell -p "$out/share/quickshell-bar" "$@"
          EOF
          chmod +x $out/bin/quickshell-bar

          # Fix the path in wrapper
          substituteInPlace $out/bin/quickshell-bar \
            --replace '$out' "$out"
        '';
      };
    in
    {
      packages.${system} = {
        default = topBar;
        quickshell-bar = topBar;
        quickshell = quickshellPkg;
      };

      # NixOS module for easy integration
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          services.upower.enable = true;
          networking.networkmanager.enable = lib.mkDefault true;
          hardware.bluetooth.enable = lib.mkDefault true;

          environment.systemPackages = [
            topBar
            quickshellPkg
          ];
        };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          quickshellPkg
          pkgs.niri
        ];

        shellHook = ''
          echo "QuickShell bar development environment"
          echo "Run: quickshell -p ."
        '';
      };
    };
}
