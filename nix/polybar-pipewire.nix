{ lib
, coreutils
, stdenv
, gnused
, makeWrapper
, pipewire
, polybar-scripts
, pulseaudio
}:

stdenv.mkDerivation {
  name = "polybar-pipewire";

  src = polybar-scripts;

  doUnpack = false;

  doBuild = false;

  nativeBuildInputs = [
    makeWrapper
  ];

  patchPhase = ''
    patchShebangs polybar-scripts/pipewire
  '';

  installPhase = ''
    mkdir -vp $out/bin
    mv -v polybar-scripts/pipewire/pipewire.sh $out/bin/
    wrapProgram $out/bin/pipewire.sh \
      --suffix PATH : "${lib.makeBinPath [ coreutils gnused pipewire pulseaudio ]}"
  '';
}
