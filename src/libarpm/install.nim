import
  std/[os, options, osproc, strutils, tables, tempfiles, posix],
  ./[io, storage, package_list, package, helpers, dependencies, downloaders, env],
  zippy/ziparchives

const
  BASE_BINPKG_REPO {.strdefine.} =
    "https://raw.githubusercontent.com/ArgonLinux/bin-packages/master/gen-bin/"

proc getFirstDirectory*(dir: string): Option[string] =
  for kind, path in walkDir(dir):
    if kind != pcDir:
      continue

    return some(path)

proc install*(
  package: Package, 
  force: bool = false,
  list: PackageList = packageList(),
  reason: InstallationReason = Direct
) =
  if isPackageInstalled(package.name) and not force:
    info "Package is already installed. Use `--force` if you want to reinstall it."
    return

  let dir = createTempDir("libarpm_", '_' & package.name)

  info "Fetching source from `" & package.fetch.url & '`'
  
  case package.fetch.meth
  of FetchMethod.Http:
    httpDownload(package.fetch.url, dir)
  of FetchMethod.Git:
    gitClone(package.fetch.url, dir)

  let cwd = getCurrentDir()
  info "Setting current directory to `" & dir & "`"
  let environment = inheritEnvironment()
  setCurrentDir(dir)
  for cmd in package.build:
    info "Executing build command: `" & cmd & '`'
    if (let code = execCmdEx(cmd, env = environment).exitCode; code != 0):
      error("Build command exited with non-zero exit code: " & $code & "; cannot continue.", true)

  for dest, src in package.files:
    let file = dir / dest

    root:
      info("Copying file: \"" & file & "\" to \"" & src & '\"')
      copyFile(dest, src)

      setFilePermissions(file, {fpUserExec, fpUserRead, fpOthersExec, fpOthersRead, fpGroupExec, fpGroupRead})

      if chown(
        file,
        1000, 100
      ) != 0:
        error("Failed to modify permissions for package file: " & file, true)
  
  setCurrentDir(cwd)
  markAsInstalled(package)
