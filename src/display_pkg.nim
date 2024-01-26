import libarpm/[package, io, helpers], libarpm/parsers/[licenses, maintainer]

proc display*(package: Package) {.inline.} =
  echo GREEN & package.name & RESET & ' ' & YELLOW & $package.version & RESET
  echo '\t' & GREEN & "License:    " & RESET & BOLD & $package.license
  echo '\t' & GREEN & "Maintainer: " & RESET & BOLD & $package.maintainer
