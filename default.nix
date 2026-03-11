{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "ninjabrain-bot";
  version = "1.5.2-unstable";
in
pkgs.maven.buildMavenPackage {
  inherit pname;
  inherit version;

  mvnHash = "sha256-xqlV8VdK34cHBn1rjiVgtAKS6YyNfdT3P22Xnt27l0g=";

  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = with pkgs; [
    maven
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    jdk
    jna
  ];

  runtimeDependencies = with pkgs; [
    libxkbcommon
    xorg.libXtst
    xorg.libX11
    xorg.libXt
    xorg.libXinerama
  ];

  mvnParameters = pkgs.lib.escapeShellArgs [
    "assembly:single"
    "-DskipTests"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 target/ninjabrainbot-1.5.2-PRE1-jar-with-dependencies.jar $out/share/java/ninjabrainbot.jar

    makeWrapper ${pkgs.jdk}/bin/java $out/bin/ninjabrainbot \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            libxkbcommon
            xorg.libXtst
            xorg.libX11
            xorg.libXt
            xorg.libXinerama
          ]
        )
      } \
      --add-flags "-cp $out/share/java/ninjabrainbot.jar" \
      --add-flags "ninjabrainbot.Main"

    runHook postInstall
  '';
}
