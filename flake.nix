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
    yices_src_2_5_4 = {
      url = "github:SRI-CSL/yices2/Yices-2.5.4";
      flake = false;
    };
    yices_src_2_6_1 = {
      url = "github:SRI-CSL/yices2/Yices-2.6.1";
      flake = false;
    };
    yices_src_2_6_2 = {
      url = "github:SRI-CSL/yices2/Yices-2.6.2";
      flake = false;
    };
    yices_src_2_6_3 = {
      url = "github:SRI-CSL/yices2/Yices-2.6.3";
      flake = false;
    };
    yices_src_2_6_4 = {
      url = "github:SRI-CSL/yices2/Yices-2.6.4";
      flake = false;
    };
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

  outputs = inps:
    inps.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = inps.nixpkgs.legacyPackages.${system};
          cleanVer = builtins.replaceStrings ["."] ["_"];
          mkZ3 = version:
            pkgs.z3.overrideAttrs (_: {
              inherit version;
              src = inps."${"z3_src_" + cleanVer version}";
            });
          mkYices = version:
            pkgs.yices.overrideAttrs (_: {
              inherit version;
              src = inps."${"yices_src_" + cleanVer version}";
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
          yices = pkgs.yices // { # whatever the nixpkgs current version is...
            v2_6   = mkYices "2.6.4";
            v2_6_4 = mkYices "2.6.4";
            v2_6_3 = mkYices "2.6.3";
            v2_6_2 = mkYices "2.6.2";
            v2_6_1 = mkYices "2.6.1";
            v2_5_4 = mkYices "2.5.4";
            v2_5   = mkYices "2.5.4";
          };
        };
      });
}
