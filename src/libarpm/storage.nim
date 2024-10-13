import std/[os, options, json, hashes]
import ./[package, io, helpers]

const BASE_STORAGE {.strdefine.} = "/etc/arpm.d"

proc existsOrCreateStorageDir*(subdirectories: seq[string]) =
  root:
    if not dirExists("/etc/arpm.d"):
      info "Creating storage directory (" & BASE_STORAGE & ")"
      createDir(BASE_STORAGE)

    for sub in subdirectories:
      if not dirExists(sub):
        info "Creating sub-directory in storage directory (" & BASE_STORAGE & '/' & sub &
          ')'
        createDir(BASE_STORAGE / sub)

proc writePackageList*(name: string, data: string) {.inline.} =
  root:
    existsOrCreateStorageDir(@["repos"])
    writeFile(BASE_STORAGE / "repos" / name & ".argon", data)

proc getPackageList*(name: string): Option[string] =
  info "Fetching pre-saved repository: " & name & ".argon"

  let path = BASE_STORAGE / "repos" / name & ".argon"

  if not fileExists(path):
    warn "Pre-saved repository not found: " & path
    return none(string)

  some(readFile(path))

proc createInstalledList*(path: string): string {.inline.} =
  info "Creating installed-package list for the first run!"

  let
    data =
      """
[
]
"""

  root:
    writeFile(path, data)

  data

proc getInstalledList*(): string =
  let path = BASE_STORAGE / "installed_db.argon"
  if not fileExists(path):
    warn "Could not find list of installed packages: " & path
    return createInstalledList(path)

  readFile(path)

proc isPackageInstalled*(name: string): bool =
  let list = getInstalledList().parseJson()

  for pkg in list.getElems():
    if pkg["name"].getStr() == name:
      return true

  false

proc markAsInstalled*(pkg: Package) =
  root:
    info "Marking \"" & pkg.name & "\" as installed."

    let
      path = BASE_STORAGE / "installed_db.argon"
      list = getInstalledList()

    var final: JsonNode

    final = list.parseJson()

    final.add(%*pkg)

    writeFile(path, $final)

proc markAsUninstalled*(pkg: Package) =
  root:
    info "Marking \"" & pkg.name & "\" as uninstalled."

    let
      path = BASE_STORAGE / "installed_db.argon"
      list = getInstalledList()

    var final = newJArray()
    let data = list.parseJson()
    
    for installedPkg in data:
      let fromJson = package(installedPkg)
      if fromJson == pkg:
        continue

      final &= installedPkg

    writeFile(path, $final)
