with import <nixpkgs> { };

mkShell {
  nativeBuildInputs = [
    openssl.dev
    curl.dev
    simdutf
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    openssl.dev
    curl.dev
    simdutf
  ];
}
