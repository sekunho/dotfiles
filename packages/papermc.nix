{ lib, stdenv, fetchurl, bash, jre }:

stdenv.mkDerivation rec {
  pname = "papermc";
  version = "1.19.4.514";

  jar = let
    mcVersion = lib.versions.pad 3 version;
    buildNum = builtins.elemAt (lib.versions.splitVersion version) 3;
  in fetchurl {
    url = "https://papermc.io/api/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
    sha256 = "sha256-fFE5U75b1DGsUROuNaXl/d2r1I1AwOlVvNRx91zrfl4=";
  };

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    cat > minecraft-server << EOF
    #!${bash}/bin/sh
    exec ${jre}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
  '';

  installPhase = ''
    install -Dm444 ${jar} $out/share/papermc/papermc.jar
    install -Dm555 -t $out/bin minecraft-server
  '';
}
