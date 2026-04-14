{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "ninjabrain-bot";
  version = "1.5.2-unstable";
  runtimeDependencies = with pkgs; [
    libxkbcommon
    xorg.libXtst
    xorg.libX11
    xorg.libXt
    xorg.libXinerama
  ];
in
pkgs.maven.buildMavenPackage {
  inherit pname;
  inherit version;

  mvnHash = "sha256-xqlV8VdK34cHBn1rjiVgtAKS6YyNfdT3P22Xnt27l0g=";

  src = pkgs.lib.cleanSource ./.;

  nativeBuildInputs = with pkgs; [
    maven
    makeWrapper
  ];

  buildInputs = with pkgs; [
    jdk
    jna
  ];

  inherit runtimeDependencies;

  mvnParameters = pkgs.lib.escapeShellArgs [
    "assembly:single"
    "-DskipTests"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 target/ninjabrainbot-1.5.2-jar-with-dependencies.jar $out/share/java/ninjabrainbot.jar

    makeWrapper ${pkgs.jdk}/bin/java $out/bin/ninjabrainbot \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (runtimeDependencies)} \
      --add-flags "-cp $out/share/java/ninjabrainbot.jar" \
      --add-flags "ninjabrainbot.Main"

    runHook postInstall
  '';
}
