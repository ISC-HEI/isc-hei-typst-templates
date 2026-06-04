{
  description = "Development Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =

    {
      self,
      nixpkgs,
      flake-utils,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        fontsConf = pkgs.makeFontsConf {
          fontDirectories = with pkgs; [
            fira-code
            source-sans
            source-sans-pro
            inriafonts
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            typst
            tinymist
            just
            pngquant
            zopfli
          ];

          shellHook = ''
            export FONTCONFIG_FILE="${fontsConf}"
          '';
        };
      }
    );
}
