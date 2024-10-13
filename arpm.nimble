# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "The Argon Package Manager"
license       = "GPL-2.0-only"
srcDir        = "src"
backend       = "cpp"
bin           = @["arpm"]

# Dependencies

requires "nim >= 2.0.0"
requires "librng >= 0.1.1"
requires "nancy >= 0.1.1"
requires "termstyle >= 0.1.0"
requires "semver >= 1.2.0"
requires "zippy >= 0.10.11"
requires "toml_serialization >= 0.2.10"
requires "crunchy >= 0.1.9"

taskRequires "fmt", "nph >= 0.3.0"
task fmt, "Make sure to run this before committing your changes! (runs nph)":
  exec "nph src/"

requires "curly >= 1.1.1"

requires "jsony >= 1.1.5"