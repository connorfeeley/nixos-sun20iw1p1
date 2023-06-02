{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }: {
    overlays.default = import ./overlay.nix;
    legacyPackages =
      let
        riscv64-linux-patched = (import nixpkgs {
          system = "riscv64-linux";
          overlays = [ self.overlays.default ];
        }).applyPatches {
          name = "nixpkgs-patched-234218";
          src = nixpkgs;
          patches = [ ./nixos-nixpkgs-234128.patch ];
        };
        x86_64-linux-patched = (import nixpkgs {
          system = "x86_64-linux";
          overlays = [ self.overlays.default ];
        }).applyPatches {
          name = "nixpkgs-patched-234218";
          src = nixpkgs;
          patches = [ ./nixos-nixpkgs-234128.patch ];
        };
      in
        {
          riscv64-linux = import riscv64-linux-patched { system = "riscv64-linux"; };

          # legacyPackages.x86_64-linux.pkgsCross.riscv64
          x86_64-linux = import x86_64-linux-patched { system = "x86_64-linux"; };
        };
    nixosModules = {
      sd-image-licheerv = import ./sd-image-licheerv.nix;
    };
    nixosConfigurations = {
      sdImageLicheeRVInstaller = nixpkgs.lib.nixosSystem {
        # Set system modularly (nixpkgs.hostPlatform)
        system = null;
        modules = [ ./sd-image-licheerv-installer.nix ];
      };
    };

    devShells.x86_64-linux.default = with self.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        gcc
        binutils
        dtc
        swig
        (python3.withPackages (p: [ p.libfdt p.setuptools ]))
        pkg-config
        ncurses
        nettools
        bc
        bison
        flex
        perl
        rsync
        gmp
        libmpc
        mpfr
        openssl
        libelf
        cpio
        elfutils
        zstd
        gawk
        zlib
        pahole
      ];
    };
  };
}
