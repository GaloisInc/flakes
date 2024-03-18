# This is a wrapper that enables the use of build-bom when building a package,
# adding a "bc" output that will contain any extracted LLVM IR bitcode files.
#
# To use it, simply specify it as a new target, passing any adjustment arguments
# in an argument set, followed by the main derivation as an argument.  For
# example:
#
# openssl-bc = build-bom-wrapper {} pkgs.openssl;
#
# Note that a default-build-bom is passed, but the user may override this. This
# is to provide an alternative to the fix-point evaluation of pkgs that is
# difficult to provide from the top-level flake, to support cases where the
# build-bom used here must be modified by the user (e.g. to allow modifications
# like: impureEnvVars = [ "HTTP_PROXY" "HTTPS_PROXY" ]).

{ pkgs, default-build-bom
, gnumake, gnutar, bintools
}:

{ clang ? pkgs.clang_16
, llvm ? pkgs.llvm_16
, build-bom ? default-build-bom
, extra-build-bom-flags ? []
, extra-buildInputs ? []
}:

drv:
let
  defaultBuilder = "${pkgs.bash}/bin/bash";
  updDrv =
    let drv1 = drv.overrideAttrs (oldAttrs:
          (bld oldAttrs) //
          {
            nativeBuildInputs = bldInputs oldAttrs;
            NIX_CC_USE_RESPONSE_FILE=0;  # do not use a response file for args
            NIX_HARDENING_ENABLE="";  # disable hardening
          });
    in drv1;
  bld = oldAttrs:
    if builtins.elem pkgs.wafHook (oldAttrs.buildInputs or []) ||
       builtins.elem pkgs.wafHook (oldAttrs.propagatedBuildInputs or [])
    then
      # Adding the wafHook causes waf build/install operations to be inserted by
      # setup_hook at execution time, not at the derivation specification time
      # (does this violate process hash generation?), so this must be manually
      # overridden here.  Copied/modified from
      # nixpkgs/pkgs/development/tools/build-managers/waf/setup-hook.sh with
      # escaping and prefixing the waf invocation with build-bom.
      {
        buildPhase = ''
          runHook preBuild

          # set to empty if unset
          : "''${wafFlags=}"

          local flagsArray=(
            ''${enableParallelBuilding:+-j ''${NIX_BUILD_CORES}}
            $wafFlags ''${wafFlagsArray[@]}
            $wafBuildFlags ''${wafBuildFlagsArray[@]}
            ''${wafBuildTargets:-build}
          )

          echoCmd 'waf build flags' "''${flagsArray[@]}"
          ${build-bom}/bin/build-bom generate-bitcode ${builtins.concatStringsSep " " extra-build-bom-flags} -- python "$wafPath" "''${flagsArray[@]}"

          runHook postBuild
        '';
      }
    else
      if oldAttrs ? buildPhase
      then {
        buildPhase = ''
          echo "building with build-bom and existing build phase"
          ${build-bom}/bin/build-bom generate-bitcode ${builtins.concatStringsSep " " extra-build-bom-flags} -- ${pkgs.bash}/bin/bash -c "${oldAttrs.buildPhase}"
        '';
      }
      else {
        # copied from nixpkgs/pkgs/stdenv/generic/setup.sh, with escaping and
        # replacing the invocation of make with make via build-bom.  Extended to
        # *directly* support waf (the waf hook re-configures during setupPhase,
        # rather than directly updating the derivation, so this side-steps that
        # by looking for the waf file and performing the waf build).
        buildPhase = ''
          runHook preBuild

          _accumFlagsArray() {
              local name
              if [ -n "''$__structuredAttrs" ]; then
                  for name in "''$@"; do
                      local -n nameref="$name"
                      flagsArray+=( ''${nameref+"''${nameref[@]}"} )
                  done
              else
                  for name in "''$@"; do
                      local -n nameref="''$name"
                      case "''$name" in
                          *Array)
                              flagsArray+=( ''${nameref+"''${nameref[@]}"} ) ;;
                          *)
                              flagsArray+=( ''${nameref-} ) ;;
                      esac
                  done
              fi
          }

          if [[ -z "''${makeFlags-}" && -z "''${makefile:-}" && ! ( -e Makefile || -e makefile || -e GNUmakefile ) ]]; then
              echo "no Makefile or custom buildPhase, doing nothing"
          else
              foundMakefile=1

              # shellcheck disable=SC2086
              local flagsArray=(
                  ''${enableParallelBuilding:+-j''${NIX_BUILD_CORES}}
                  SHELL=$SHELL
              )
              _accumFlagsArray makeFlags makeFlagsArray buildFlags buildFlagsArray

              echoCmd 'build flags' "''${flagsArray[@]}"
              ${build-bom}/bin/build-bom generate-bitcode ${builtins.concatStringsSep " " extra-build-bom-flags} -- ${gnumake}/bin/make ''${makefile:+-f $makefile} "''${flagsArray[@]}"
              unset flagsArray
          fi

          runHook postBuild
        '';
      };
  bldInputs = oldAttrs:
    let moreInputs = [
          clang
          llvm
          bintools
          gnutar
        ];
        fullInputs = (oldAttrs.nativeBuildInputs or []) ++
                     moreInputs ++
                     extra-buildInputs;
    in fullInputs;
  gen_bc_out = forTgts: ''
      echo generate $bc from $out for ${forTgts}
      mkdir $out
      cp -r ${forTgts}/* $out/

      mkdir $bc
      extract_bc() {
        (
          cd $1
          for X in $(${pkgs.findutils}/bin/find . -type f); do
            if ${pkgs.file}/bin/file $X | grep -q ELF ; then
              mkdir -p $bc/$(dirname $X)
              ${build-bom}/bin/build-bom extract-bitcode -v \
                  --llvm-link ${llvm}/bin/llvm-link \
                  --objcopy ${bintools}/bin/objcopy \
                  $X -o $bc/$X.bc
            fi
          done
        )
      }

      if [ "X$out" != "X" ] ; then extract_bc $out; fi
      if [ "X$bin" != "X" ] ; then extract_bc $bin; fi
  '';

  wrapDrv = pkgs.stdenv.mkDerivation {
    name = drv.name + "-bc";
    src = updDrv.src;
    buildPhase = "";
    installPhase = gen_bc_out updDrv.out;
    outputs = [ "out" "bc" ];
  };

in wrapDrv
