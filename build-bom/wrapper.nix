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

{ clang ? pkgs.clang_14
, llvm ? pkgs.llvm_14
, build-bom ? default-build-bom
, extra-build-bom-flags ? ""
, extra-buildInputs ? []
}:

drv: drv.overrideAttrs(oldAttrs:
  let
    bld =
      if oldAttrs ? buildPhase
      then {
        buildPhase = ''
          ${build-bom}/bin/build-bom generate-bitcode -- /bin/bash -c "${oldAttrs.buildPhase}"
        '';
      }
      else {
        # copied from nixpkgs/pkgs/stdenv/generic/setup.sh, with escaping and
        # replacing the invocation of make with make via build-bom.
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
              ${build-bom}/bin/build-bom generate-bitcode ${extra-build-bom-flags} -- ${gnumake}/bin/make ''${makefile:+-f $makefile} "''${flagsArray[@]}"
              unset flagsArray
          fi

          runHook postBuild
        '';
      };
  in bld // rec {
    outputs = (oldAttrs.outputs or [ "out" ]) ++ [ "bc" ];
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
      clang
      llvm
      bintools
      gnutar
    ] ++ extra-buildInputs;
    postInstall = ''
      mkdir $bc
      extract_bc() {
        cd $1
        for X in $(${pkgs.findutils}/bin/find . -type f); do
          if ${pkgs.file}/bin/file $X | grep -q ELF ; then
            mkdir -p $bc/$(dirname $X)
            ${build-bom}/bin/build-bom extract-bitcode -o $bc/$X.bc $X
          fi
        done
      }

      if [ "X$out" != "X" ] ; then extract_bc $out; fi
      if [ "X$bin" != "X" ] ; then extract_bc $bin; fi

      ${oldAttrs.postInstall or "# nada"}
      '';
})
