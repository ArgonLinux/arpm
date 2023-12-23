# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "The Argon Package Manager"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["arpm"]


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/ArgonLinux/libarpm >= 0.1.0"
