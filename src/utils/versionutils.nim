import libarpm/io, semver

proc toStyledString*(ver: Version): string =
  result = GREEN & $ver.major & '.' & $ver.minor & '.' & $ver.patch & RESET

  if ver.build.len > 0:
    result &= '-' & YELLOW & ver.build & RESET

  if ver.metadata.len > 0:
    result &= ':' & RED & ver.metadata & RESET
