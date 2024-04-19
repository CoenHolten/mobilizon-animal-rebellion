{
  description = "Mobilizon";

  inputs = {};

  outputs = { self }: {
    packages.x86_64-linux.nixosModules.default = { ... }: {
      nixpkgs.overlays = [ (final: prev: {
        mobilizon = prev.callPackage ./nix {
          elixir = prev.elixir_1_15;
          beamPackages = prev.beamPackages.extend (self: super: { elixir = prev.elixir_1_15; });
          mobilizon-frontend = prev.callPackage ./nix/frontend.nix { };
        };
      })];
    };
  };
}
