{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  diffutils,
  gmp,
  pkg-config,
  which,
}:

stdenv.mkDerivation rec {
  name = "cocoalib";
  version = "0.99800";

  src = fetchurl {
    url = "https://cocoa.altervista.org/cocoalib/tgz/CoCoALib-0.99800.tgz";
    hash = "sha256-+Lsifi4XKeFxz3rCAIr3HfJZFGB3EsNdt7y1oESpKMY=";
  };

  patches = [
    # Adapted from https://github.com/cocoa-official/CoCoALib/pull/90
    ./pkgconfig.patch
    # Taken from CVC5:
    # https://github.com/cvc5/cvc5/blob/6f9eb83f0bfa10929519045730bec47c70c16967/cmake/deps-utils/CoCoALib-0.99800-trace.patch
    ./CoCoALib-0.99800-trace.patch
  ];

  buildInputs = [ gmp ];

  nativeBuildInputs = [
    pkg-config
    which
  ];

  postPatch = ''
    SCRIPTS_TO_PATCH="$(find . -name '*.sh' -print)"
    MAKEFILES_TO_PATCH="$(find . -name 'Makefile' -print)"
    patchShebangs configure $SCRIPTS_TO_PATCH
    for file in configure $SCRIPTS_TO_PATCH $MAKEFILES_TO_PATCH; do
      substituteInPlace "$file" \
        --replace /bin/cat ${coreutils}/bin/cat \
        --replace /bin/cp ${coreutils}/bin/cp \
        --replace /bin/mkdir ${coreutils}/bin/mkdir \
        --replace /bin/ln ${coreutils}/bin/ln \
        --replace /bin/ls ${coreutils}/bin/ls \
        --replace /bin/mv ${coreutils}/bin/mv \
        --replace /bin/rm ${coreutils}/bin/rm \
        --replace /usr/bin/cmp ${diffutils}/bin/cmp
    done
  '';

  preConfigure = ''
    mkdir -p $out/include
    mkdir -p $out/lib
  '';

  meta = {
    description = "Computations in Commutative Algebra";
    homepage    = "https://cocoa.altervista.org/cocoalib/index.shtml";
    license     = lib.licenses.gpl3;
    platforms   = lib.platforms.unix;
  };
}
