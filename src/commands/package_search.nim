import std/options,
       ../display_pkg,
       libarpm/[io, package_list]

proc packageSearch*(targets: seq[string], forceSync: bool = false) =
  let list = packageList(refresh=forceSync)

  if targets.len < 1:
    error("No packages supplied for searching!", true)
  
  for p in targets:
    let pkg = list.getPackage(p)

    if pkg.isSome:
      pkg.get()
        .display()
    else:
      error("Package not found: " & p, true)
