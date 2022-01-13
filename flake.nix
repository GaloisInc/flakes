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
    nixpkgs.url = "github:nixos/nixpkgs/21.11";
    flake-utils.url = "github:numtide/flake-utils";
    boolector_src_3_2_2 = {
      url = "github:boolector/boolector/3.2.2";
      flake = false;
    };
    boolector_src_3_2_1 = {
      url = "github:boolector/boolector/3.2.1";
      flake = false;
    };
    boolector_src_3_2_0 = {
      url = "github:boolector/boolector/3.2.0";
      flake = false;
    };
    boolector_src_3_1_0 = {
      url = "github:boolector/boolector/3.1.0";
      flake = false;
    };
    cvc4_src_1_8 = {
      url = "github:cvc4/cvc4/1.8";
      flake = false;
    };
    cvc4_src_1_7 = {
      url = "github:cvc4/cvc4/1.7";
      flake = false;
    };
    stp_src_2_3_3 = {
      url = "github:stp/stp/2.3.3";
      flake = false;
    };
    stp_src_2_3_2 = {
      url = "github:stp/stp/2.3.2";
      flake = false;
    };
    stp_src_2_3_1 = {
      url = "github:stp/stp/2.3.1";
      flake = false;
    };
    stp_src_2_2_0 = {
      url = "github:stp/stp/stp-2.2.0";
      flake = false;
    };
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
          mkVerPkg = pkg: version:
            pkgs.${pkg}.overrideAttrs  (_: {
              inherit version;
              src = inps."${pkg + "_src_" + cleanVer version}";
            });
          mkBoolector = mkVerPkg "boolector";
          mkCVC4 = mkVerPkg "cvc4";
          mkYices = mkVerPkg "yices";
          mkZ3 = mkVerPkg "z3";
          mkSTP = mkVerPkg "stp";
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
          stp = pkgs.stp // { # whatever the nixpkgs current version is...
            v2_3   = mkSTP "2.3.3";
            v2_2   = mkSTP "2.2.0";
            v2_3_3   = mkSTP "2.3.3";
            v2_3_2   = mkSTP "2.3.2";
            v2_3_1   = mkSTP "2.3.1";
            v2_2_0   = mkSTP "2.2.0";
          };
          cvc4 = pkgs.cvc4 // { # whatever the nixpkgs current version is...
            v1_8   = mkCVC4 "1.8";
            v1_7   = mkCVC4 "1.7";
            v4_1_8   = mkCVC4 "1.8";
            v4_1_7   = mkCVC4 "1.7";
          };
          boolector = pkgs.boolector // { # whatever the nixpkgs current version is...
            v3_2   = mkBoolector "3.2.2";
            v3_1   = mkBoolector "3.1.0";
            v3_2_2   = mkBoolector "3.2.2";
            v3_2_1   = mkBoolector "3.2.1";
            v3_2_0   = mkBoolector "3.2.0";
            v3_1_0   = mkBoolector "3.1.0";
          };
        };
      });
}
