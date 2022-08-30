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
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    flake-utils.url = "github:numtide/flake-utils";
    abc_src_2020_06_22 = {
      url = "github:berkeley-abc/abc/341db2566";
      flake = false;
    };
    abc_src_2021_12_30 = {
      url = "github:berkeley-abc/abc/48498af";
      flake = false;
    };
    bitwuzla_unstable_2021_07_01 = {
      url = "github:bitwuzla/bitwuzla/58d720598e359b1fdfec4a469c76f1d1f24db51a";
      flake = false;
    };
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
    cvc5_src_1_0_0 = {
      url = "github:cvc5/cvc5/cvc5-1.0.0";
      flake = false;
    };
    cvc5_src_1_0_1 = {
      url = "github:cvc5/cvc5/cvc5-1.0.1";
      flake = false;
    };
    cvc5_src_1_0_2 = {
      url = "github:cvc5/cvc5/cvc5-1.0.2";
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
      url = "github:z3prover/z3/z3-4.8.11";
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
          mkABC = version:
            pkgs.abc-verifier.overrideAttrs (_: {
              name = "abc";
              inherit version;
              src = inps."${"abc_src_" + version}";
            });
          mkBitwuzla = mkVerPkg "bitwuzla";
          mkBoolector = mkVerPkg "boolector";
          mkCVC4 = version:
            let basePkg = mkVerPkg "cvc4" version;
            in basePkg.overrideAttrs (old: {
              buildInputs = old.buildInputs ++ [ pkgs.symfpu ];
              # Adding --symfpu to configureFlags is ineffective ?!
              # configureFlags = old.configureFlags ++ [ "--symfpu" ];
              cmakeFlags = old.cmakeFlags ++ [ "-DUSE_SYMFPU=ON" ];
            });
          mkCVC5 = mkVerPkg "cvc5";
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
          cvc5 = pkgs.cvc5 // { # whatever the nixpkgs current version is...
            v1_0_0  = mkCVC5 "1.0.0";
            v1_0_1  = mkCVC5 "1.0.1";
            v1_0_2  = mkCVC5 "1.0.2";
          };
          bitwuzla = pkgs.bitwuzla // { # whatever the nixpkgs current version is...
            vunstable_2021_07_01 = mkBitwuzla "unstable-2021-07-01";
          };
          boolector = pkgs.boolector // { # whatever the nixpkgs current version is...
            v3_2   = mkBoolector "3.2.2";
            v3_1   = mkBoolector "3.1.0";
            v3_2_2   = mkBoolector "3.2.2";
            v3_2_1   = mkBoolector "3.2.1";
            v3_2_0   = mkBoolector "3.2.0";
            v3_1_0   = mkBoolector "3.1.0";
          };
          abc = pkgs.abc-verifier // {
            v2020_06_22 = mkABC "2020_06_22";
            v2021_12_30 = mkABC "2021_12_30";
          };
        };
      });
}
