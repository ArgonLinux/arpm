import std/[os, osproc, options]
import zippy/ziparchives
import ./[helpers, io]

proc gitClone*(url: string, dir: string) =
  info "Cloning Git repository to `" & dir & '`'

  if (let res = execCmdEx(findExe("git") & " clone " & url & ' ' & dir & " --depth=1"); res.exitCode != 0):
    error("Git clone failed with non-zero exit code: " & $res.exitCode)
    error("Git output: " & res.output, true)

proc httpDownload*(url: string, dir: string, extract: bool = true) =
  info "Downloading file to `" & $dir & '`'

  let data = httpGet(url)

  if data.isNone:
    error("Failed to download HTTP file!", true)

  let content = get data
  info "Fetched " & $content.len & " bytes."
  writeFile(dir & ".zip", content)

  if extract:
    info "Decompressing source"
    extractAll(dir & ".zip", dir)
