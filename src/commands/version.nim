import std/[json, options]
import ../libarpm/io

const NimblePkgVersion {.strdefine.} = "??? (not defined during compile time)"

proc humanReadable*() =
  echo "arpm@" & GREEN & NimblePkgVersion & RESET

  echo "\n\tcompiled with Nim " & GREEN & NimVersion & RESET
  echo "\tcompiled at " & GREEN & CompileDate & RESET & ' ' & YELLOW & CompileTime &
    RESET
  echo "\tcompiled for " & GREEN & hostCPU & RESET

  echo '\n'
  echo BOLD & "arpm" & RESET & " and" & BOLD & " libarpm" & RESET &
    " are developed by the Argon Linux project."
  echo "All code is licensed under the" & GREEN & " GNU General Public License V2" &
    RESET
  quit(0)

proc jsonFmt*() =
  echo $(
    %*{
      "arpm": NimblePkgVersion,
      "nim_compiler": NimVersion,
      "compile_date": CompileDate,
      "compile_time": CompileTime,
      "host_cpu": hostCPU
    }
  )
  quit(0)

proc version*(format: Option[string]) =
  if not format.isSome:
    humanReadable()

  let fmt = get format

  case fmt
  of "json":
    jsonFmt()
  of "arpm_ver":
    echo NimblePkgVersion
  else:
    error("Invalid version command format: " & fmt, true)
