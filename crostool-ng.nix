{ pkgs ? import <nixpkgs> {} }:

with pkgs; let
  mforce = pkgs.fetchurl {
    url = "https://github.com/jcmvbkbc/gcc-xtensa/commit/6b0c9f92fb8e11c6be098febb4f502f6af37cd35.patch";
    sha256 = "1cfdh7jvgg66x4xfbr1zsx7bgrcmj7y81l2wknfc7shdf69ybfax";
  };
in pkgs.stdenv.mkDerivation {
  name = "crostool-ng-esp8266";
  version = "1.22.x";
  src = pkgs.fetchgit {
    url = "https://github.com/jcmvbkbc/crosstool-NG.git";
    rev = "a4286b8c9b61a48ee802cf633f0ff19c6cf10ae5";
    sha256 = "0iw4j7gdh8jw65xfd10c2353vq2mcwvm2avj91zs7283bbb154fa";
  };

  nativeBuildInputs = with pkgs; [
    autoconf automake aria coreutils curl cvs
    gcc git python which file wget
  ];

  # https://unix.stackexchange.com/questions/356232/disabling-the-security-hardening-options-for-a-nix-shell-environment#367990
  hardeningDisable = [ "format" ];

  buildInputs = [
    bison flex gperf help2man libtool ncurses texinfo
  ];

  configurePhase = ''
    cp ${mforce} local-patches/gcc/4.8.5/1000-mforce-l32.patch
    ./bootstrap;
    ./configure --enable-local --disable-static
    make;
    echo "CT_LOCAL_TARBALLS_DIR=\"\$\{CT_TOP_DIR\}/tars\"" >> ./samples/xtensa-lx106-elf/crosstool.config;
    echo "CT_FORBID_DOWNLOAD=y" >> ./samples/xtensa-lx106-elf/crosstool.config;
    echo "CT_LIBC_NEWLIB_ENABLE_TARGET_OPTSPACE=y" >> ./samples/xtensa-lx106-elf/crosstool.config;
    ./ct-ng xtensa-lx106-elf
    mkdir tars;
  '' +
  toString ( map ( p: "ln -s " + fetchurl { inherit (p) url sha256; } + " ./tars/" + p.name + ";\n" ) [
    { # new
      name = "mpfr-3.1.3.tar.xz";
      url = "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.xz";
      sha256 = "05jaa5z78lvrayld09nyr0v27c1m5dm9l7kr85v2bj4jv65s0db8";
    }{
      name = "isl-0.14.tar.xz";
      url = "http://isl.gforge.inria.fr/isl-0.14.tar.xz";
      sha256 = "00zz0dcxvbna2fqqqv37sqlkqpffb2js47q7qy7p184xh414y15i";
    }{
      name = "cloog-0.18.4.tar.gz";
      url = "http://bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz";
      sha256 = "03km1aqaiy3sbqc2f046ms9x0mlmacxlvs5rxsvjj8nf20vxynij";
    }{
      name = "mpc-1.0.3.tar.gz";
      url = "http://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz";
      sha256 = "1hzci2zrrd7v3g1jk35qindq05hbl0bhjcyyisq9z209xb3fqzb1";
    } {
      name = "expat-2.1.0.tar.gz";
      url = "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz";
      sha256 = "11pblz61zyxh68s5pdcbhc30ha1b2vfjd83aiwfg4vc15x3hadw2";
    }{
      name = "ncurses-6.0.tar.gz";
      url = "http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.0.tar.gz";
      sha256 = "0q3jck7lna77z5r42f13c4xglc7azd19pxfrjrpgp2yf615w4lgm";
    }{
      name = "binutils-2.25.1.tar.gz";
      url = "http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.gz";
      sha256 = "1z335dm8pv33ildpnik35q7xi8bmcj28fzmc6v5zl4isn4vhm942";
    }{
      name = "gcc-4.8.5.tar.gz";
      url = "http://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.gz";
      sha256 = "0ni9v0vd744llppgqa6lvg7c6i3zvrlyb66jzxfzwiwr9kcmrg0x";
    }{
      name = "newlib-2.0.0.tar.gz";
      url = "http://mirrors.kernel.org/sourceware/newlib/newlib-2.0.0.tar.gz";
      sha256 = "12idyyd7dmn01z44f3j44k89dmyw7ms2ka0s48xpqpij568rxhj9";
    }{
      name = "gdb-7.10.tar.xz";
      url = "http://mirrors.kernel.org/sourceware/gdb/releases/gdb-7.10.tar.xz";
      sha256 = "1a08c9svaihqmz2mm44il1gwa810gmwkckns8b0y0v3qz52amgby";
    }{
      name = "gmp-6.0.0a.tar.xz";
      url = "https://gmplib.org/download/gmp/gmp-6.0.0a.tar.xz";
      sha256 = "0r5pp27cy7ch3dg5v0rsny8bib1zfvrza6027g2mp5f6v8pd6mli";
    }
  ]);

  buildPhase = ''
    ./ct-ng build;
  '';

  installPhase = ''
    ls -la
    cp -avr ./builds/xtensa-lx106-elf/ $out
  '';
}
