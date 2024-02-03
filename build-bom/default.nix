{ pkgs
# , clang ? pkgs.clang_12
# , llvm ? pkgs.llvm_12
, src ? pkgs.fetchFromGitHub
  { owner = "travitch"; repo = "build-bom";
    rev = "14602f7"; # "master";
  }
, postUnpack ? null
}:

builtins.trace ("generating build-bom " + (if postUnpack == null then "regular" else "with postUnpack"))
pkgs.rustPlatform.buildRustPackage {
  pname = "build-bom";
  version = "0.1.0";
  src = src;
  doCheck = false;
  nativeBuildInputs = [ pkgs.clang_12 pkgs.llvm_12 ];
  # cargoSha256 = lib.fakeSha256;
  cargoSha256 = "sha256-k2NGJWj8IKMeNUTbdSFquaqcDCN+lBNzpfc7HAXufrA=";
  inherit postUnpack;
}
