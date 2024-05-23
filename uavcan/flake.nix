{
    inputs = {
        nixpkgs.url = github:nixos/nixpkgs/20.09;
        levers = {
            url = "github:kquick/nix-levers";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        galois-flakes.url = "github:GaloisInc/flakes";
        uavcan-src = {
          url = "github:Ardupilot/uavcan/3ef4b88";
          flake = false;
        };
        uavcan_DSDL-src = {
          url = "github:UAVCAN/dsdl/192295c";
          flake = false;
        };
        pyuavcan-src = {
          url = "github:UAVCAN/pyuavcan/c58477a";
          flake = false;
        };
    };

    outputs = { self, nixpkgs, levers, galois-flakes
              , uavcan-src
              , uavcan_DSDL-src
              , pyuavcan-src
              , ... }:
    {
      packages = levers.eachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = self.packages.${system}.uavcan;

          # n.b. use clang; using gcc causes errors because the nixpkgs 20.09
          # supports flexible arrays (__glibc_c99_flexarr_available) but these
          # are not the last element of the uavcan-defined structures, so errors
          # occur during compilation.  This does not happen when using clang (7).

          uavcan = pkgs.clangStdenv.mkDerivation {
              name = "uavcan";
              src = uavcan-src;
              nativeBuildInputs = [ pkgs.cmake pkgs.python2 ];
              preConfigure = ''
                rmdir dsdl
                ln -s ${uavcan_DSDL-src} ./dsdl
                rmdir libuavcan/dsdl_compiler/pyuavcan
                ln -s ${pyuavcan-src} ./libuavcan/dsdl_compiler/pyuavcan
              '';
          };

          dsdl = uavcan_DSDL-src;
        });
    };

}
