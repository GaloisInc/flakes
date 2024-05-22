{
    inputs = {
        nixpkgs.url = github:nixos/nixpkgs/23.11;
        levers = {
            url = "github:kquick/nix-levers";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        galois-flakes.url = "github:GaloisInc/flakes";
        build-bom.url = "github:GaloisInc/flakes?dir=build-bom";
        ardupilot-src = {
          url = "github:ArduPilot/ardupilot/43adaf3"; # master version; versions for following inputs mirror git submodule settings
          flake = false;
        };
        ardupilot-patches = {
          url = "./patches";
          flake = false;
        };
        empy-src = {
          url = "http://www.alcyone.com/software/empy/empy-3.3.4.tar.gz";
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
        mavproxy-src = {
          url = "github:ardupilot/mavproxy";
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
        dronecan_dsdlc-src = {
          url = "github:DroneCAN/dronecan_dsdlc/2465ace";
            flake = false;
        };
        lwip-src = {
            url = "github:ArduPilot/lwip/143a6a5";
            flake = false;
        };
        CANBUS = {
          url = "/home/kquick/work/galois-flakes-git2023/pydronecan";
        };
    };

    outputs = { self, nixpkgs, levers, build-bom, galois-flakes
              , ardupilot-src
              , ardupilot-patches
              , empy-src
              , waf-src
              , libcanard-src
              , mavlink-src
              , mavproxy-src
              , pymavlink-src
              , googletest-src
              , dronecan_dsdlc-src
              , lwip-src
              , CANBUS
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
            use-build-bom = galois-flakes.outputs.packages."${system}".build-bom-wrapper
              {
                extra-build-bom-flags = [
                  # "-E"
                  # "-v"

                  # AP_Common.c tries to ensure the right size for float
                  # constants via "static_assert(sizeof(1e6) == sizeof(float),
                  # ...)" which is obtained in gcc via
                  # -fsingle-precision-constant, but clang's version is
                  # -cl-single-precision-constant
                  "--inject-argument=-cl-single-precision-constant"
                ];
                # extra-buildInputs = [ pkgs.pkgsCross.gnu32.cmake ];
                build-bom = build-bom.packages.${system}.build-bom;
                # Use older clang/llvm because newer has import problems
                clang = pkgs.clang_12;
                llvm = pkgs.llvm_12;
              };
        in {
          default = self.packages.${system}.sitl_bc;

          empy = pkgs.python3Packages.buildPythonPackage rec {
              name = "empy";
              src = empy-src;
              doCheck = false;
              pythonImportsCheck = [ "em" ];
              format = "setuptools";
          };
          mavproxy = pkgs.python3Packages.buildPythonPackage rec {
              name = "mavproxy";
              src = mavproxy-src;
              propagatedBuildInputs =
                let pp = pkgs.python3Packages; in [
                      self.packages.${system}.pymavlink
                      pp.pyserial
                      pp.numpy
                    ];
              doCheck = false;
              pythonImportsCheck = [ "MAVProxy" ];
              format = "setuptools";
          };

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
          dronecan = CANBUS.packages.${system}.pydronecan or
            CANBUS.packages.${system}.uavcan;
          sim_vehicle = pkgs.stdenv.mkDerivation {
            name = "sim_vehicle";
            version = "1.0";
            src = "${ardupilot-src}/Tools/autotest";
            configurePhase = "";
            buildPhase = ''
              cat > sim_vehicle << EOF
              #!/usr/bin/env bash
              set -x
              export PATH=$PATH
              export PYTHONPATH=${self.packages.${system}.mavproxy}/lib:$out/lib:$PYTHONPATH
              echo Defaulting to arducopter via --vehicle-binary=${self.packages.${system}.sitl}/bin/arducopter
              echo Override via explicit --vehicle-binary specification
              python3 $out/bin/Tools/autotest/sim_vehicle.py --no-rebuild --no-configure --vehicle-binary=${self.packages.${system}.sitl}/bin/arducopter "\''${@}"
              EOF
              sed -i -e '/TMUX/s,screen",screen" -o "$TERM" = "screen-256color",' run_in_terminal_window.sh
            '';
            buildInputs = [
              pkgs.python3
              self.packages.${system}.sitl
              self.packages.${system}.mavproxy
            ];
            propagatedBuildInputs =
              let pp = pkgs.python3Packages;
              in [
                pp.pexpect
                pkgs.procps
                pkgs.tmux
                pkgs.xterm
              ];
            installPhase = ''
              mkdir -p $out/bin/Tools/autotest
              cp sim_vehicle.py $out/bin/Tools/autotest/
              install run_in_terminal_window.sh $out/bin/Tools/autotest/
              mkdir -p $out/lib/pysim
              cp -r pysim/* $out/lib/pysim/

              # sim_vehicle.py has some baked-in assumptions
              mkdir -p $out/bin/{ArduCopter,ArduPlane,ArduSub,Blimp,Rover}

              mkdir $out/bin/Tools/autotest/default_params
              cp -r default_params/* $out/bin/Tools/autotest/default_params

              install sim_vehicle $out/bin/
            '';
            # Usage: sim_vehicle --console --map --osd -v ArduCopter
            # KWQ: not fully working yet
          };
          sitl =
            let tgts = [
                  "all"
                  # copter heli plane rover sub antennatracker AP_Periph
                ];
                waf_flags = [
                  "--board" "sitl"
                  "--no-submodule-update"
                  # "--prefix=$out"
                ];
            in pkgs.stdenv.mkDerivation {
              name = "ardupilot-sitl";
              version = "1.0";
              src = ardupilot-src;
              buildInputs = [
                  pkgs.gcc
                  pkgs.wafHook
                  self.packages.${system}.pymavlink
              ] ++ (with pkgs.python3Packages; [
                  self.packages.${system}.empy
                  pexpect
                  setuptools
                  self.packages.${system}.dronecan
              ]);
              wafConfigureFlags = waf_flags;
              wafBuildTargets = tgts;
              wafBuildFlags = waf_flags;
              wafInstallTargets = tgts;
              # n.b. the waf configuration does not seem to want to install into
              # --prefix, --destdir, or --out, so it's done manually in the
              # postInstall hook here.
              wafInstallFlags = waf_flags;
              postInstall = ''
                mkdir $out/bin
                cp build/sitl/bin/* $out/bin/
              '';
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
                [ -d modules/DroneCAN ] && ln -s ${CANBUS.packages.${system}.dsdl} modules/DroneCAN/DSDL

                [ -d modules/DroneCAN/dronecan_dsdlc ] && rmdir modules/DroneCAN/dronecan_dsdlc || true
                [ -d modules/DroneCAN ] && ln -s ${dronecan_dsdlc-src} modules/DroneCAN/dronecan_dsdlc

                # [ -d modules/DroneCAN/pydronecan ] && rmdir modules/DroneCAN/pydronecan || true
                [ -d modules/DroneCAN/libcanard ] && rmdir modules/DroneCAN/libcanard || true
                [ -d modules/DroneCAN ] && ln -s ${libcanard-src} modules/DroneCAN/libcanard

                [ -d modules/lwip ] && rmdir modules/lwip || true
                ln -s ${lwip-src} modules/lwip

                # Ensure that the build process can see the pydronecan package
                export PYTHONPATH=${self.packages.${system}.dronecan}/lib/python*/site-packages:$PYTHONPATH
              '';
              patches =
                # Apply all patches in the specified input location.  This allows
                # override of the patches applied if the ardupilot-source is
                # overridden.
                let contents = builtins.readDir ardupilot-patches;
                    isFile = n: contents.${n} == "regular";
                    files = builtins.filter isFile (builtins.attrNames contents);
                    fullPath = f: "${ardupilot-patches}/${f}";
                    patchfiles = builtins.map fullPath files;
                in patchfiles;
          };
          sitl_bc = use-build-bom self.packages.${system}.sitl;
        });
    };

}
