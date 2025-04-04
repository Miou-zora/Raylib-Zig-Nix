{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };
  outputs = { self, nixpkgs, flake-utils, zig-overlay }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        # Refer to https://github.com/mitchellh/zig-overlay if you want to use a specific version of Zig
        zigPackage = zig-overlay.packages.${system}."0.14.0";
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          name = "name_of_your_project";
          packages = with pkgs; [
            raylib
          ];
          nativeBuildInputs = [
            zigPackage
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "name_of_your_project";
          src = ./.;

          XDG_CACHE_HOME = "${placeholder "out"}";

          buildInputs = [ pkgs.raylib ];
          buildPhase = ''
            ${zigPackage}/bin/zig build
          '';

          installPhase = ''
            ${zigPackage}/bin/zig build install --prefix $out
            rm -rf $out/zig # remove cache
          '';
        };
      });
}
