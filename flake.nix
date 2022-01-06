{
  description = "Nix flakes maintained by Galois";

  # Example Usage:
  #
  #   $ nix build github:GaloisInc/flakes#z3.v4_8_14
  #   $ result/bin/z3 --version
  #   Z3 version 4.8.14 - 64 bit
  #
  # or just:
  #
  #   $ nix run github:GaloisInc/flakes#z3.v4_8_14 -- -version

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    z3_src_4_8_8 = {
      url = "github:z3prover/z3/z3-4.8.8";
      flake = false;
    };
    z3_src_4_8_9 = {
      url = "github:z3prover/z3/z3-4.8.9";
      flake = false;
    };
    z3_src_4_8_10 = {
      url = "github:z3prover/z3/z3-4.8.10";
      flake = false;
    };
    z3_src_4_8_11 = {
      url = "github:z3prover/z3/z3-4.8.10";
      flake = false;
    };
    z3_src_4_8_12 = {
      url = "github:z3prover/z3/z3-4.8.12";
      flake = false;
    };
    z3_src_4_8_13 = {
      url = "github:z3prover/z3/z3-4.8.13";
      flake = false;
    };
    z3_src_4_8_14 = {
      url = "github:z3prover/z3/z3-4.8.14";
      flake = false;
    };
  };

  outputs = inps@{ self, flake-utils, nixpkgs
                 , z3_src_4_8_8
                 , z3_src_4_8_9
                 , z3_src_4_8_10
                 , z3_src_4_8_11
                 , z3_src_4_8_12
                 , z3_src_4_8_13
                 , z3_src_4_8_14
                 }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          mkZ3 = version:
            pkgs.z3.overrideAttrs (_: {
              inherit version;
              src = inps."${"z3_src_" + builtins.replaceStrings ["."] ["_"] version}";
            });
      in
      {
        packages = rec {
          z3 = pkgs.z3 // {  # whatever the nixpkgs current version is...
            v4_8_8 = mkZ3 "4.8.8";
            v4_8_9 = mkZ3 "4.8.9";
            v4_8_10 = mkZ3 "4.8.10";
            v4_8_11 = mkZ3 "4.8.11";
            v4_8_12 = mkZ3 "4.8.12";
            v4_8_13 = mkZ3 "4.8.13";
            v4_8_14 = mkZ3 "4.8.14";
          };
        };
      });
}
