{
  pkgs ? import <nixpkgs> { },
}:
let
  project = import ./. { inherit pkgs; };
in
pkgs.mkShell {

  inputsFrom = [ project ];

  nativeBuildInputs = with pkgs; [
    llvmPackages_19.clang-tools
    doxygen
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (project.runtimeDependencies)}

    alias run='mvn exec:java -Dexec.mainClass="ninjabrainbot.Main"'
  '';
}
