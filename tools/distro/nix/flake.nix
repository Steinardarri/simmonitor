{
  description = "simmonitor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    simapi.url = "git+file:/home/steinardth/Forrit/git_verkefni/-SimRacing/simapi?shallow=1&dir=tools/distro/nix";
  };

  outputs = {
    self,
    nixpkgs,
    simapi,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      hoel = pkgs.stdenv.mkDerivation {
        pname = "hoel";
        version = "2024-03-04";

        src = pkgs.fetchFromGitHub {
          owner = "babelouest";
          repo = "hoel";
          rev = "33598d2c8defc4eeff208249b5bed67c7ed62e48";
          sha256 = "sha256-ZOCVStiljdCcdG4mBnREUPhJOo+VTxUzA+BxKWQt5hA=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        buildInputs = with pkgs; [
          orcania
          jansson
          libpq
          libpq.pg_config
          yder
        ];

        cmakeFlags = [
          "-DWITH_MARIADB=off"
          "-DWITH_SQLITE3=off"
          "-DCMAKE_INSTALL_PREFIX=$out"
        ];
      };

      simmonitor = pkgs.stdenv.mkDerivation {
        pname = "simmonitor";
        version = "1.0.0";

        src = ./../../..;

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        buildInputs = [
          simapi.packages.${system}.default
          self.packages.${system}.hoel
          pkgs.argtable
          pkgs.hidapi
          pkgs.lua53Packages.lua
          pkgs.libconfig
          pkgs.libpulseaudio
          pkgs.libserialport
          pkgs.libuv
          pkgs.libusb1
          pkgs.libxml2
          pkgs.libxdg_basedir
          pkgs.ncurses
          pkgs.freetype
          pkgs.libmicrohttpd
          pkgs.SDL2
          pkgs.SDL2_image
          pkgs.libtar
          pkgs.jansson
          pkgs.libpq
          pkgs.libdrm
          pkgs.libwebp
          pkgs.libtiff
          pkgs.xorg.libX11
          pkgs.yder
          pkgs.orcania
          pkgs.postgresql
        ];

        cmakeFlags = [
          "-DCMAKE_BUILD_TYPE=Release"
          "-DCMAKE_INSTALL_PREFIX=$(out)"
          "-Wno-dev"
        ];

        postPatch = ''
          substituteInPlace src/simmonitor/helper/parameters.c \
            --replace-warn 'argtable2.h' 'argtable3.h'

          substituteInPlace $(find . -name CMakeLists.txt) \
            --replace-warn 'argtable2' 'argtable3'
        '';

        # installPhase = ''
        #   mkdir -p $out/bin
        #   install -m755 -D simmonitor $out/bin/simmonitor
        # '';

        meta = with pkgs.lib; {
          description = "Customizable Simulator dashboards and telemetry data logger";
          homepage = "https://github.com/Spacefreak18/simmonitor";
          license = licenses.gpl3Only;
          # maintainers = [ maintainers.yourName ];  # Replace with your name
          platforms = platforms.linux;
        };
      };
    };
  };
}
