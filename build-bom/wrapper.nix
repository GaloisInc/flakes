# This is a wrapper that enables the use of build-bom when building a package,
# adding a "bc" output that will contain any extracted LLVM IR bitcode files.
#
# To use it, simply specify it as a new target, passing the main derivation as an argument.  For example:
#
# openssl-bc = build-bom-wrapper pkgs.openssl;

{ pkgs, build-bom
, clang ? pkgs.clang_12
, llvm ? pkgs.llvm_12
}:

drv: drv.overrideAttrs(oldAttrs:
  let bld = if oldAttrs ? buildPhase
            then {
              buildPhase = ''
                ${build-bom}/bin/build-bom generate-bitcode -- /bin/bash -c "${oldAttrs.buildPhase}"
              '';
            }
            else {
              MAKE="${build-bom}/bin/build-bom generate-bitcode -- make";
            };
  in bld // rec {
    outputs = (oldAttrs.outputs or [ "out" ]) ++ [ "bc" ];
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
      clang
      llvm
      pkgs.bintools
    ];
    postInstall = ''
      ${oldAttrs.postInstall or "# nada"}

      mkdir $bc
      (set -e
       for X in $out/bin/* $bin/bin/*; do
         if ${pkgs.file}/bin/file $X | grep -q ELF ; then
           ${build-bom}/bin/build-bom extract-bitcode -o $bc/$(basename $X).bc $X
         fi
       done
      )
      '';
})
