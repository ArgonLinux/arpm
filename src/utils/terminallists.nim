import std/terminal, libarpm, versionutils

proc getPackageString*(package: Package): string =
  BOLD & package.name & RESET & '\t' & GREEN & toStyledString(package.version) & RESET

proc drawPackageList*(
  pkgs: seq[Package]
) =
  let
    termWidth = terminalWidth()
    termHeight = terminalHeight()

  for pkg in pkgs:
    echo "* " & getPackageString(pkg)
