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

    nixpkgs_2205.url = "github:nixos/nixpkgs/22.05";
    # nixpkgs circa 22.05 is sufficient to build z3, yices, boolector (check
    # disabled), cvc4, cvc5, and stp, but not bitwizla_0_3_0.

    # nixpkgs circa 23.05 or later is needed for bitwuzla_0_3_0 (specifically for
    # meson >= 0.64), but 23.05 or later fails for:
    #
    #    * yices-2.5.4, (multiple definition of smt_opcodes_)t
    #      during linking)
    #
    #    * cvc5-1.0.0, cvc5-1.0.1, cvc5-1.0.2, nixpkgs 23.05
    #
    #      (src/parser/smt2/Smt2.g:
    #         Decision can match input such as "LPAREN_TOK INDEX_TOK" using multiple alternatives: 1, 2
    #         As a result, alteriative(s) 2 were disabled for that input
    #       src/expr/node_manager_template.h:0
    #         undefined replacement ${metakind_mkConstDelete}
    #      )
    #
    #    * cvc5-1.0.0 through cvc5-1.0.6, nixpkgs 23.11
    #
    #      configuration fails because these older cvc5 versions use python with
    #      the "toml" package, which is deprecated in favor of the "tomli"
    #      package and is therefore not part of the later nixpkgs version.
    #
    # using: gcc 12.2, openjdk-19.0.2
    nixpkgs.url = "github:nixos/nixpkgs/23.11";

    flake-utils.url = "github:numtide/flake-utils";
    abc_src_2020_06_22 = {
      url = "github:berkeley-abc/abc/341db2566";
      flake = false;
    };
    abc_src_2021_12_30 = {
      url = "github:berkeley-abc/abc/48498af";
      flake = false;
    };
    bitwuzla_src_0_3_0 = {
      url = "github:bitwuzla/bitwuzla/0.3.0";
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
    build-bom-src = {
      url = "github:travitch/build-bom";
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
    cvc5_src_1_0_3 = {
      url = "github:cvc5/cvc5/cvc5-1.0.3";
      flake = false;
    };
    cvc5_src_1_0_6 = {
      url = "github:cvc5/cvc5/cvc5-1.0.6";
      flake = false;
    };
    cvc5_src_1_0_7 = {
      url = "github:cvc5/cvc5/cvc5-1.0.7";
      flake = false;
    };
    cvc5_src_1_0_8 = {
      url = "github:cvc5/cvc5/cvc5-1.0.8";
      flake = false;
    };
    cvc5_src_1_0_9 = {
      url = "github:cvc5/cvc5/cvc5-1.0.9";
      flake = false;
    };
    cvc5_src_1_1_0 = {
      url = "github:cvc5/cvc5/cvc5-1.1.0";
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
    # -- n.b. yices odd versions (e.g. 2.6.3) are dev versions, even versions are
    # -- release versions.  Stick to release versions here.
    yices_src_2_5_4 = {
      url = "github:SRI-CSL/yices2/Yices-2.5.4";
      flake = false;
    };
    yices_src_2_6_2 = {
      url = "github:SRI-CSL/yices2/Yices-2.6.2";
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

  outputs = inps@{ self, ... }:
    inps.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = inps.nixpkgs.legacyPackages.${system};
          pkgs22 = inps.nixpkgs_2205.legacyPackages.${system};
          cleanVer = builtins.replaceStrings ["."] ["_"];
          # The mkVerPkg will build the package as specified by the *current*
          # pkgs specification (imported from nixpkgs), but adjusting the src and
          # version to the specified target.  This (lazy methodology) assumes
          # that the build process is valid for each target src/version
          # specified; where this is not the case, a more specific directive is
          # given (e.g. yices-2.5.4).  A possible future, more disciplined
          # approach would be to maintain local build instructions that can be
          # adjusted for each version, providing better separation from nixpkgs
          # dependencies, but losing the benefit of common development efforts.
          mkVerPkg = pkg: version:
            pkgs.${pkg}.overrideAttrs  (_: {
              inherit version;
              src = inps."${pkg + "_src_" + cleanVer version}";
            });
          mkVerPkg22 = pkg: version:
            pkgs22.${pkg}.overrideAttrs  (_: {
              inherit version;
              src = inps."${pkg + "_src_" + cleanVer version}";
            });
          mkABC = version:
            pkgs.abc-verifier.overrideAttrs (_: {
              name = "abc";
              inherit version;
              src = inps."${"abc_src_" + version}";
            });
          mkBitwuzla = version:
            # Using a local bitwuzla build specification until
            # https://github.com/NixOS/nixpkgs/pull/246779 is merged and
            # generally availble in pkg, at whic point this can just be mkVerPkg
            # and the local build specification can be removed.
            let bw = pkgs.callPackage "${self}/bitwuzla" {};
                pkg = "bitwuzla";
            in bw.overrideAttrs (_: {
              inherit version;
              src = inps."${pkg + "_src_" + cleanVer version}";
            });
          mkBoolector = mkVerPkg "boolector";
          mkCVC4 = version:
            let basePkg = mkVerPkg "cvc4" version;
            in basePkg.overrideAttrs (old: {
              buildInputs = old.buildInputs ++ [ pkgs.symfpu ];
              # Adding --symfpu to configureFlags is ineffective ?!
              # configureFlags = old.configureFlags ++ [ "--symfpu" ];
              cmakeFlags = (old.cmakeFlags or []) ++ [ "-DUSE_SYMFPU=ON" ];
            });
          mkCVC5 = mkVerPkg "cvc5";
          mk22CVC5 = mkVerPkg22 "cvc5";
          mkYices = mkVerPkg "yices";
          mk22Yices = mkVerPkg22 "yices";
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
          yices = pkgs.yices // rec { # whatever the nixpkgs current version is...
            v2_6   = v2_6_4;
            v2_5   = v2_5_4;
            v2_6_4 = mkYices "2.6.4";
            v2_6_2 = mkYices "2.6.2";
            v2_5_4 = mk22Yices "2.5.4";
          };
          stp = pkgs.stp // rec { # whatever the nixpkgs current version is...
            v2_3   = mkSTP "2.3.3";
            v2_2   = v2_2_0;
            v2_3_3   = mkSTP "2.3.3";
            v2_3_2   = mkSTP "2.3.2";
            v2_3_1   = mkSTP "2.3.1";
            v2_2_0   = mkVerPkg22 "stp" "2.2.0";
          };
          cvc4 = pkgs.cvc4 // { # whatever the nixpkgs current version is...
            v1_8   = mkCVC4 "1.8";
            v1_7   = mkCVC4 "1.7";
            v4_1_8   = mkCVC4 "1.8";
            v4_1_7   = mkCVC4 "1.7";
          };
          cvc5 = pkgs.cvc5 // rec { # whatever the nixpkgs current version is...
            v1_0  = v1_0_9;
            v1_1  = v1_1_0;
            v1_0_0  = mk22CVC5 "1.0.0";
            v1_0_1  = mk22CVC5 "1.0.1";
            v1_0_2  = mk22CVC5 "1.0.2";
            v1_0_3  = mk22CVC5 "1.0.3";
            # n.b. v 1.0.4 and 1.0.5 have dependencies on the obsolete python
            # "toml" package, which isn't available under nixpkgs.  These are
            # older anyhow, so these are skipped.
            v1_0_6  = mkCVC5 "1.0.6";
            v1_0_7  = mkCVC5 "1.0.7";
            v1_0_8  = mkCVC5 "1.0.8";
            v1_0_9  = mkCVC5 "1.0.9";
            v1_1_0  = mkCVC5 "1.1.0";
          };
          boolector = pkgs.boolector // rec { # whatever the nixpkgs current version is...
            v3_2   = mkBoolector "3.2.2";
            v3_1   = v3_1_0;
            v3_2_2   = mkBoolector "3.2.2";
            v3_2_1   = mkBoolector "3.2.1";
            v3_2_0   = mkBoolector "3.2.0";
            v3_1_0   = (mkBoolector "3.1.0").overrideAttrs(o:
              {
                cmakeFlags = o.cmakeFlags ++ [ "-DUSE_CADICAL=YES" ];
                buildInputs = o.buildInputs ++ [ pkgs.cadical ];
              });
          };
          abc = pkgs.abc-verifier // {
            v2020_06_22 = mkABC "2020_06_22";
            v2021_12_30 = mkABC "2021_12_30";
          };
          bitwuzla = mkBitwuzla "0_3_0" // {
            v0_3_0 = mkBitwuzla "0_3_0";
          };

          # -------------------------------------------------

          build-bom = import "${self}/build-bom" {
            inherit pkgs;
            src = inps.build-bom-src;
          };
          build-bom-wrapper = import "${self}/build-bom/wrapper.nix" {
            inherit pkgs build-bom;
            clang = pkgs.clang_14;
            llvm = pkgs.llvm_14;
          };
        };
      });
}
