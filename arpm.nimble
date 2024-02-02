# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "The Argon Package Manager"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["arpm"]


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/ArgonLinux/libarpm >= 0.1.1"

# Extra libraries
requires "librng >= 0.1.1"
requires "nancy >= 0.1.1"
requires "termstyle >= 0.1.0"
requires "nph >= 0.3.0"

task fmt, "Make sure to run this before committing your changes! (runs nph)":
  exec "nph src/"
