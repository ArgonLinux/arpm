import std/[os, strtabs]

proc inheritEnvironment*: StringTableRef =
  newStringTable({
    "PATH": getEnv("PATH")
  })
