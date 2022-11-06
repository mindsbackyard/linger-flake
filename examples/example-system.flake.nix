## This is an example flake-based NixOS configuration to show the use of the linger-flake.
## The configuration is not complete and it is assued that a `./configuration.nix` and `./hardware.nix` exists.
## The example will activate lingering for the user "alice" and manage the linger settings for all other users (except root)
## on the system.
{
  inputs = {
    # Opinionated: Even if you don't use flake-utils in your config declare the dependency here
    # s.t. if multiple flakes depend on the same input we can force them to use the same version.
    flake-utils.url = "github:numtide/flake-utils";

    linger = {
      url = "github:mindsbackyard/linger-flake";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, linger, ... }:
    let
      system = "x86_64-linux";
      # use x86_64 packages from nixpkgs
      pkgs = nixpkgs.legacyPackages.${system};

    in {
      nixosConfigurations."nixos-example-system" = nixpkgs.lib.nixosSystem {
        # nixosSystem needs to know the system architecture
        inherit system;
        modules = [
          # a small module for enabling nix flakes
          { ... }: {
            nix = {
              packge = pkgs.nixFlakes;
              extraOptions = "experimental-features = nix-command flake";

              # Opinionated: use system flake's (locked) `nixpkgs` as default `nixpkgs` for flake commands
              # see https://dataswamp.org/~solene/2022-07-20-nixos-flakes-command-sync-with-system.html
              registry.nixpkgs.flake = nixpkgs;
            };
          }

          # some existing system & hardware configuration modules; it is assumed that a user named `alice` is defined here
          ./configuration.nix
          ./hardware.nix

          # make the module declared by the linger flake available to our config
          linger.nixosModules.${system}.default

          # in another module we can now configure the lingering behaviour (could also be part of ./configuration.nix)
          { ... }: {
            services.linger = {
              enable = true;

              # as we are configuring the linger flake explicitly we also want to leave it in full control of the feature
              manageAllUsers = true;

              # only processes of the (non-root) user `alice` will now be allowed to linger without a user session
              users = [ "alice" ];
            };
          }
        ];
      };
    };
}
