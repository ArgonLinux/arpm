## This is used by the package aggregator in ArgonLinux/packages, it's just integrated into the libarpm codebase.

import ../parsers/[licenses], toml_serialization, semver

type
  RawPackageInfo* = object
    package*: string
    version: string
    description*: string
    architecture*: seq[string]
    license*: string

  PackageInfoCore* = object
    name*: string
    version*: Version
    description*: string
    architecture*: seq[string]
    license*: License

  PackageSourceCore* = object
    files*, sha256sums*: seq[string]

  PackageInfo = object
    info*: PackageInfoCore
    source*: PackageSourceCore

proc packageInfo*(data: string): PackageInfo =
  let raw = Toml.decode(data, RawPackageInfo, "info")

  let
    core =
      PackageInfoCore(
        name: raw.package,
        version: raw.version.parseVersion(),
        description: raw.description,
        architecture: raw.architecture,
        license: raw.license.parseLicense(),
      )

  let source = Toml.decode(data, PackageSourceCore, "source")

  PackageInfo(info: core, source: source)
