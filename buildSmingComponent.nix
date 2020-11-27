{ stdenvNoCC, python3, git, esp-open-sdk, sming, findutils, coreutils, gnumake }:

{name, src, preBuild ? null}: stdenvNoCC.mkDerivation {
  name = "sming-component-${name}";
  phases = ["unpackPhase" "buildPhase" "installPhase"];

  inherit preBuild src;

  ESP_HOME="${esp-open-sdk}";

  unpackPhase = ''
    cp -ra ${sming} Sming
    chmod +w -R Sming

    export SMING_HOME=$(readlink -f Sming/Sming)

    cp -r $src $SMING_HOME/Components/${name}
    chmod +w -R $SMING_HOME

    mkdir project
    pushd project
    echo "include \$(SMING_HOME)/project.mk" > Makefile
    echo "COMPONENT_DEPENDS := ${name}" > component.mk

    mkdir -p app
    echo -e "void init() {}\n" > app/application.cpp
  '';

  buildPhase = ''
    runHook preBuild

    make
    make SMING_RELEASE=1

    popd
  '';

  nativeBuildInputs = [
    coreutils gnumake git python3 findutils
  ];

  installPhase = ''
    mkdir $out
    pushd $NIX_BUILD_TOP/Sming/
    cp --parents `find . -type f -newer README.md -iname "clib-*.a"` $out
    cp --parents `find . -type f -newer README.md -iname "*.d"` $out
    cp --parents `find . -type f -newer README.md -iname "*.o"` $out
    cp --parents `find Sming/Components -type f -newer README.md` $out
    popd
  '';
}
