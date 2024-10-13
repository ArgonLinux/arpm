import std/[os, json, tables]
import ./[storage, io, helpers, package, package_list]

proc uninstall*(package: Package, force, refresh: bool = false) =
  if not isPackageInstalled(package.name) and not force:
    error("Package not installed: " & package.name)
    error("If you believe that this is a bug, use `--force` to bypass this check.", true)

  for _, file in package.files:
    if not fileExists(file):
      warn("File not found: " & file & "; ignoring.")

    root:
      removeFile(file)

  markAsUninstalled(package)
