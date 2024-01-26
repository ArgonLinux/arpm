import std/options, libarpm/[io, package_list], ../display_pkg

proc repositoryLs*(forced: bool = false) =
  let list = packageList(refresh = forced)

  for pkg in list.packages:
    display(pkg)
