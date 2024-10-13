import std/[strutils, json, tables]
import ./parsers/[licenses, maintainer]
import ./helpers

import semver except `$`

type
  InstallationReason* = enum
    Direct ## This package was installed directly by the user.
    Indirect ## This package was installed as a dependency of another package.

  PackageMetadata* = object
    reason*: InstallationReason ## Why was this package installed?
    freedom*: FreedomType ## What freedom does this package give you?
  
  FetchMethod* {.pure.} = enum
    Git
    Http

  PackageFetch* = object
    url*: string
    meth*: FetchMethod

  Package* = object
    name*: string ## The package's name
    version*: Version ## The package's semantic version
    maintainer*: Maintainer ## The package's maintainer on Argon
    license*: License ## The package's license

    depends*, provides*: seq[string] ## What packages this depends upon and provides to
    optional_depends*: seq[string] ## What does this package optionally depend upon

    metadata*: PackageMetadata ## Other information
    files*: Table[string, string] ## Files belonging to this package. (<file in build folder> -> <where the file should be placed>)
    build*: seq[string] ## Compilation/build commands
    fetch*: PackageFetch

proc toJson*(package: Package): string =
  pretty (%*package)

proc isLibre*(package: Package): bool {.inline.} =
  ## Check if this package is libre (or as the FSF calls it, free as in freedom, not as in free beer).
  ##
  ## **See also:**
  ## * `isOss proc`_
  ## * `isProprietary proc`_
  isLibre package.license

proc isOss*(package: Package): bool {.inline.} =
  ## Check if this package is open source software (there is a clear distinction between OSS and libre, go check it out.)
  ##
  ## **See also:**
  ## * `isProprietary proc`_
  ## * `isLibre proc`_
  isOss package.license

proc isProprietary*(package: Package): bool {.inline.} =
  ## Check if this package is proprietary (i.e, it was not compiled by Argon developers and only the authors have the source code and 
  ## they reserve certain rights to it.)
  ##
  ## **See also:**
  ## * `isLibre proc`_
  ## * `isOss proc`_
  isProprietary package.license

proc `>`*(package: Package, against: Package): bool {.inline.} =
  package.version > against.version

proc `<`*(package: Package, against: Package): bool {.inline.} =
  package.version < against.version

proc `>=`*(package: Package, against: Package): bool {.inline.} =
  package.version >= against.version

proc `<=`*(package: Package, against: Package): bool {.inline.} =
  package.version <= against.version

proc `==`*(package: Package, against: Package): bool {.inline.} =
  package.version == against.version

proc package*(
    name, version, maintainer, license: string,
    depends, optionalDepends, provides: seq[string] = @[], files: Table[string, string],
): Package =
  ## Create a new `Package`
  ##
  ## **See also:**
  ## * `package proc`_ to create a `Package` from a `JsonNode`
  Package(
    name: name,
    version: version.parseVersion(),
    maintainer: maintainer.parseMaintainer(),
    license: license.parseLicense(),
    depends: depends,
    provides: provides,
    files: files,
    optionalDepends: optionalDepends,
  )

proc package*(node: JsonNode): Package =
  ## Create a new `Package` from a `JsonNode`, given that it has all the elements needed.
  ## If those elements are not present, an error will be raised.
  ##
  ## **See also:**
  ## * `package proc`_ to create a `Package` from a bunch of strings and string sequences
  var
    rawDepends = node["depends"].getElems()
    rawProvides = node["provides"].getElems()
    rawOptionalDepends: seq[JsonNode]
    rawFiles = node["files"].getFields()
    rawBuild = node["build"].getElems()
    rawFetch = node["fetch"].getFields()

    rawVersion = node["version"]
    version: Version

    depends, provides, optionalDepends, build: seq[string]
    files: Table[string, string]
    fetch: PackageFetch
    maintainer: Maintainer

  try:
    version = rawVersion.getStr().parseVersion()
  except ParseError:
    version = rawVersion.version()

  if "optional_depends" in node:
    rawOptionalDepends = node["optional_depends"].getElems()
  elif "optionalDepends" in node:
    rawOptionalDepends = node["optionalDepends"].getElems()

  for d in rawDepends:
    depends.add getStr(d)

  for p in rawProvides:
    provides.add getStr(p) # god damn it, we don't depend on what we provide!

  for od in rawOptionalDepends:
    optionalDepends.add getStr(od)

  for k, v in rawFiles:
    files[k] = getStr(v)

  for inst in rawBuild:
    build &= getStr(inst)

  fetch.url = rawFetch["url"].getStr()

  fetch.meth = case (if "method" in rawFetch: rawFetch["method"].getStr() else: rawFetch["meth"].getStr()).toLowerAscii()
  of "git": FetchMethod.Git
  of "http": FetchMethod.Http
  else: 
    raise newException(ValueError, "Invalid fetch method: " & $fetch.meth)
  
  case node["maintainer"].kind
  of JString:
    maintainer = node["maintainer"].getStr().parseMaintainer()
  of JObject:
    let fields = node["maintainer"].getFields()
    maintainer.realName = fields["real_name"].getStr()

    for contact in fields["contacts"].getElems():
      maintainer.contacts = Contacts(
        github: fields["github"].getStr(),
        gitlab: fields["gitlab"].getStr(),
        mastodon: fields["mastodon"].getStr(),
        email: fields["email"].getStr()
      )
  else: discard

  Package(
    name: node["name"].getStr(),
    version: version,
    maintainer: maintainer,
    license: node["license"].getStr().parseLicense(),
    depends: depends,
    provides: provides,
    optionalDepends: optionalDepends,
    files: files,
    build: build,
    fetch: fetch
  )
