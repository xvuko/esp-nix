{ stdenvNoCC, python3, git, gnused, esp-open-sdk, sming }:

{ name ? "${attrs.pname}-${attrs.version}", src, release ? false, ... } @ attrs:

stdenvNoCC.mkDerivation {

  inherit name src;
  phases = ["unpackPhase" "prepareSming" "buildPhase" "installPhase"];

  ESP_HOME = esp-open-sdk;

  prepareSming = ''
    cp -r ${sming} $NIX_BUILD_TOP/Sming
    chmod +w -R $NIX_BUILD_TOP/Sming
    export SMING_HOME=$(readlink -f $NIX_BUILD_TOP/Sming/Sming)
  '';
  
  buildPhase = ''
    make
  '';

  SMING_RELEASE = if release then "1" else "";

  buildInputs = [ python3 git gnused ];

  installPhase = ''
    mkdir -p $out
    if [ -n "$SMING_RELEASE" ]
    then
      cp -r out/Esp8266/release/firmware $out/firmware
    else
      cp -r out/Esp8266/debug/firmware $out/firmware
    fi
  '';
}
