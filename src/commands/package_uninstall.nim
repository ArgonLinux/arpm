import
  std/[terminal, options],
  ../libarpm/[io, package, package_list, uninstall, helpers],
  ../[suggest, display_pkg],
  termstyle,
  nancy

proc displayPackages*(targets: seq[string], list: PackageList, noConfirm: bool) =
  var
    table: TerminalTable
    packages: seq[Package]

    skip: seq[int]

  for raw in targets:
    let pkg = list.getPackage(raw)

    if not pkg.isSome:
      list.suggest(raw)

    packages.add(get pkg)

  for i, package in packages:
    if i in skip:
      continue

    var other: Package

    if i + 1 < packages.len:
      other = packages[i + 1]

      table.add bold package.name,
        $package.version, "\t\t", bold other.name, redString other.version

      skip.add(i + 1)
    else:
      table.add bold package.name, $package.version

  table.echoTable()

  if not noConfirm and ask("Do you want to proceed?", ["y", "n"]) != 0:
    error("Operation aborted.", true)

proc uninstall*(targets: seq[string], forced, noConfirm: bool) =
  if targets.len < 1:
    error("No packages specified!", true)

  let list = packageList()

  displayPackages(targets, list, noConfirm)

  for raw in targets:
    let pkg = list.getPackage(raw)

    if pkg.isSome:
      let package = get pkg

      package.uninstall(forced)
    else:
      error("Package not found: " & raw)
      error(
        "BUG: This should never happen, because displayPackages() should quit much earlier than this stage. Report this to arpm developers!",
        true
      )
