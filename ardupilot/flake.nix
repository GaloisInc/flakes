{
    inputs = {
        nixpkgs.url = github:nixos/nixpkgs/23.11;
        levers = {
            url = "github:kquick/nix-levers";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        galois-flakes.url = "github:galoisinc/flakes";
        build-bom.url = "github:kquick/build-bom/vspells_te4";
        ardupilot-src = {
          url = "github:ArduPilot/ardupilot";
          flake = false;
        };
        waf-src = {
          url = "github:ArduPilot/waf/1b1625b";
          flake = false;
        };
        libcanard-src = {
          url = "github:DroneCAN/libcanard/0ae477b";
          flake = false;
        };
        mavlink-src = {
          url = "github:ArduPilot/mavlink/130a836";
          flake = false;
        };
        pymavlink-src = {
          url = "github:ArduPilot/pymavlink/4d8c4ff";
          flake = false;
        };
        googletest-src = {
          url = "github:ArduPilot/googletest/c5fed93";
          flake = false;
        };
        dronecan_DSDL-src = {
          url = "github:DroneCAN/DSDL/de93d9c";
          flake = false;
        };
        dronecan_dsdlc-src = {
          url = "github:DroneCAN/dronecan_dsdlc/2465ace";
            flake = false;
        };
        pydronecan-src = {
          url = "github:DroneCAN/pydronecan/1f494e9";
          flake = false;
        };
        lwip-src = {
            url = "github:ArduPilot/lwip/143a6a5";
            flake = false;
        };
    };

    outputs = { self, nixpkgs, levers, build-bom, galois-flakes
              , ardupilot-src
              , waf-src
              , libcanard-src
              , mavlink-src
              , pymavlink-src
              , googletest-src
              , dronecan_DSDL-src
              , dronecan_dsdlc-src
              , pydronecan-src
              , lwip-src
              , ... }:
    {
      apps = levers.eachSystem (s:
        {
          build-bom = {
            type = "app";
            program = "${build-bom.packages.${s}.build-bom}/bin/build-bom";
          };
          arduplane = {
            type = "app";
            program = "${self.packages.${s}.ardupilot-sitl}/bin/arduplane";
          };
          arducopter = {
            type = "app";
            program = "${self.packages.${s}.ardupilot-sitl}/bin/arducopter";
          };
          arducopter-heli = {
            type = "app";
            program = "${self.packages.${s}.ardupilot-sitl}/bin/arducopter-heli";
          };
          ardurover = {
            type = "app";
            program = "${self.packages.${s}.ardupilot-sitl}/bin/ardurover";
          };
          ardusub = {
            type = "app";
            program = "${self.packages.${s}.ardupilot-sitl}/bin/ardusub";
          };
        });
      packages = levers.eachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
            # CFS for Linux currently only supports a 32-bit target.
            tgtpkgs = pkgs.pkgsCross.gnu32;
            use-build-bom = galois-flakes.outputs.packages."${system}".build-bom-wrapper
              {
                extra-build-bom-flags = "-E --inject-argument=-m32 -v";
                extra-buildInputs = [ tgtpkgs.cmake ];
                build-bom = build-bom.packages.${system}.build-bom;
              };
        in {
          default = self.packages.${system}.copter;

          pymavlink = pkgs.python3Packages.buildPythonPackage rec {
              name = "pymavlink";
              src = pymavlink-src;
              propagatedBuildInputs =
                let pp = pkgs.python3Packages; in [
                      pp.future
                      pp.lxml
                    ];
              doCheck = false;
              pythonImportsCheck = [ "pymavlink" ];
              format = "setuptools";
              MDEF = "${mavlink-src}/message_definitions";
          };
          dronecan = pkgs.python3Packages.buildPythonPackage rec {
              name = "dronecan";
              src = pydronecan-src;
              preConfigure = ''
                ln -s ${dronecan_DSDL-src} dronecan/dsdl_specs
              '';
              propagatedBuildInputs = [

              ];
              doCheck = false;
          };
          sitl = pkgs.stdenv.mkDerivation {
              name = "ardupilot-sitl";
              version = "1.0";
              src = ardupilot-src;
              propagatedBuildInputs = [
                  pkgs.gcc
                  pkgs.wafHook
                  self.packages.${system}.pymavlink
                  self.packages.${system}.dronecan
              ] ++ (with pkgs.python3Packages; [
                  empy
                  pexpect
                  setuptools
                  self.packages.${system}.dronecan
              ]);
              wafConfigureFlags = [ "--board" "sitl"
                                    "--no-submodule-update"
                                  ];
              # Pre-configure fixes: the ardupilot waf requires that a number of
              # the submodules be actually present.  Use flake inputs to supplant
              # the use of git submodules.
              preConfigure = ''
                [ -d modules/waf ] && rmdir modules/waf || true
                # ln -s ${pkgs.waf.src} modules/waf
                ln -s ${waf-src} modules/waf
                sed -i -e "s,cfg.load('git_submodule'),if cfg.env.SUBMODULE_UPDATE: cfg.load('git_submodule')," wscript
                [ -d modules/mavlink ] && rmdir modules/mavlink || true
                ln -s ${mavlink-src} modules/mavlink
                [ -d modules/gtest ] && rmdir modules/gtest || true
                ln -s ${googletest-src} modules/gtest

                [ -d modules/DroneCAN/DSDL ] && rmdir modules/DroneCAN/DSDL || true
                ln -s ${dronecan_DSDL-src} modules/DroneCAN/DSDL
                [ -d modules/DroneCAN/dronecan_dsdlc ] && rmdir modules/DroneCAN/dronecan_dsdlc || true
                ln -s ${dronecan_dsdlc-src} modules/DroneCAN/dronecan_dsdlc

                # [ -d modules/DroneCAN/pydronecan ] && rmdir modules/DroneCAN/pydronecan || true
                # ln -s ${pydronecan-src} modules/DroneCAN/pydronecan
                # [ -d modules/DroneCAN/libcanard ] && rmdir modules/DroneCAN/libcanard || true
                # ln -s ${libcanard-src} modules/DroneCAN/libcanard

                [ -d modules/lwip ] && rmdir modules/lwip || true
                ln -s ${lwip-src} modules/lwip

                # Ensure that the build process can see the pydronecan package
                export PYTHONPATH=${self.packages.${system}.dronecan}/lib/python*/site-packages:$PYTHONPATH
              '';
              patches = [ "${self}/patch_warnings" ];
          };
        });
    };

}
