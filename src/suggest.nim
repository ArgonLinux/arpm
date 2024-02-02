import libarpm/[io, package_list], levenshtein

proc suggest*(list: PackageList, package: string, message: string = "Package not found") =
  var packages: seq[string]

  for pkg in list.packages:
    packages.add(pkg.name)

  let closest = search(package, packages)
  if closest.len > 0:
    let relevant = closest[0]
    error(message & ": " & package & "; did you mean \"" & relevant & "\"?", true)
  else:
    error(message & ": " & package, true)
