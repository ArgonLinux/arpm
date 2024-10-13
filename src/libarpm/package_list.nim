import std/[options, strutils, times, json], package, helpers, ./io, storage

const
  PKG_LIST_MIRROR {.strdefine.} =
    "https://raw.githubusercontent.com/ArgonLinux/packages/main/main.json"

type
  PackageList* = ref object
    name*: string
    revisionDate*, revisionTime*: DateTime
    packages*: seq[Package]

proc contains*(list: PackageList, package: string): bool =
  ## Check if a package list has a particular package.
  ##
  ## **See also:**
  ## * `getPackage proc`_
  for pkg in list.packages:
    if pkg.name == package:
      return true

  false

proc getPackage*(list: PackageList, package: string): Option[Package] =
  ## Get a package if it exists in this package list, otherwise get an empty option.
  ##
  ## **See also:**
  ## * `contains proc`_
  for pkg in list.packages:
    if pkg.name == package:
      return some(pkg)

proc newPackageList*(node: JsonNode): PackageList =
  ## Create a new `PackageList` from a valid `JsonNode`
  var revDate, revTime: DateTime

  let splittedRev = node["revision_date"].getStr().split(' ')

  revDate = splittedRev[0].parse("d/M/YYYY")
  revTime = splittedRev[1].parse("H:m:ss")

  let jPackages = node["packages"].getElems()
  var packages: seq[Package]

  for pkg in jPackages:
    packages.add package(pkg)

  PackageList(
    name: node["name"].getStr(),
    revisionDate: revDate,
    revisionTime: revTime,
    packages: packages,
  )

proc newPackageList*(jstr: string): PackageList {.inline.} =
  ## Parse a JSON string and create a `PackageList` from it.
  ##
  ## **See also:**
  ## * `newPackageList proc`_
  newPackageList(parseJson(jstr))

proc packageList*(refresh: bool = false): PackageList =
  ## Instantiate a package list from either a pre-existing save, or from the repositories online.
  if not refresh:
    let file = getPackageList("main")

    if file.isSome:
      if not validateJson(file.get()):
        error "Invalid package data saved, send this to Argon Linux maintainers ONLY if it isn't empty and you haven't manually tampered with it."
        error(
          "If you HAVE tampered with it, good job. You messed something up spectacularly. Run `arpm refresh --force` to re-fetch the list.",
          true
        )

      return newPackageList(file.get())

  let resp = httpGet(PKG_LIST_MIRROR)

  if not resp.isSome:
    error("Failed to download package list.", true)

  if resp.get().len < 1:
    error("Server responded successfully, but gave us an empty package list!", true)

  info "Saving package list."

  if not validateJson(resp.get()):
    error "Invalid package data provided, send this to the Argon Linux maintainers if it isn't empty: "
    error resp.get()

  writePackageList("main", resp.get())

  return newPackageList(resp.get())
