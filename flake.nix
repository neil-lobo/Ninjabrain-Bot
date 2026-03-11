{
  description = "Ninjabrain Bot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d2ed99647a4b195f0bcc440f76edfa10aeb3b743";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];

      mkPackages = nixpkgs.lib.genAttrs supportedSystems (system: rec {
        default = import ./. {
          inherit (nixpkgs.legacyPackages.${system}) pkgs;
        };
        package = default;
      });

      mkShells = nixpkgs.lib.genAttrs supportedSystems (system: {
        default = import ./shell.nix { inherit (nixpkgs.legacyPackages.${system}) pkgs; };
      });

    in
    {
      packages = mkPackages;
      devShells = mkShells;
    };
}
