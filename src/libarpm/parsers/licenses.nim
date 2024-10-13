import std/[strutils, tables], ../io

type
  ## All the licenses libarpm knows about. It lives under a rock, so please excuse it for now.
  License* = enum
    GPL2
    LGPL2
    GPL3
    LGPL3
    MIT
    BSD3
    WTFPL
    Unlicense
    MPL
    OtherFree
    Proprietary

  ## The type of freedom you're getting :nerd:
  FreedomType* = enum
    Libre ## "Aggressive" freedom. You may not make proprietary modifications.
    OSS ## General freedom. You can make proprietary modifications.
    NonFree
      ## Proprietary software. You may not re-distribute it without prior permission from the authors.

const
  Freedoms*: Table[License, FreedomType] =
    {
      GPL2: Libre,
      GPL3: Libre,
      LGPL2: Libre,
      LGPL3: Libre,
      MIT: OSS,
      BSD3: OSS,
      WTFPL: OSS,
      MPL: OSS,
      Unlicense: OSS,
      OtherFree: OSS,
      Proprietary: NonFree
    }.toTable

proc `$`*(license: License): string =
  ## Turn a license into a string
  case license
  of GPL2:
    return "GPL2"
  of GPL3:
    return "GPL3"
  of MIT:
    return "MIT"
  of BSD3:
    return "BSD3"
  of WTFPL:
    return "WTFPL"
  of Proprietary:
    return "Proprietary"
  of OtherFree:
    return "OSS"
  of MPL:
    return "MPL"
  of LGPL2:
    return "LGPL2"
  of LGPL3:
    return "LGPL3"
  of Unlicense:
    return "Unlicense"

proc parseLicense*(license: string): License =
  ## "Parse" a license, get an enum if it's valid.
  case license.toLowerAscii()
  of "gpl2":
    return GPL2
  of "gpl3":
    return GPL3
  of "mit":
    return MIT
  of "bsd3":
    return BSD3
  of "wtfpl":
    return WTFPL
  of "proprietary":
    return Proprietary
  of "oss":
    return OtherFree
  of "mpl":
    return MPL
  of "lgpl2":
    return LGPL2
  of "lgpl3":
    return LGPL3
  of "unlicense":
    return Unlicense
  else:
    error(
      "Invalid license string: " & license &
        " (expected GPL2, GPL3, MIT, BSD3, WTFPL, Proprietary, OSS, MPL)"
    )

proc isLibre*(license: License | string): bool {.inline.} =
  ## Is this license libre?
  ## https://www.gnu.org/licenses/license-list.html
  ##
  ## TL;DR, very stupid and probably incomplete explanation
  ## - Freedom to modify, redistribute the program as you want
  ## - No changes may be kept proprietary/in-house

  when license is string:
    return Freedoms[parseLicense(license)] == Libre

  when license is License:
    return Freedoms[license] == Libre

proc isOss*(license: License | string): bool {.inline.} =
  ## Is this license open-source?
  ## https://opensource.org/licenses/

  when license is string:
    return Freedoms[parseLicense(license)] == OSS

  when license is License:
    return Freedoms[license] == OSS

proc isProprietary*(license: License | string): bool {.inline.} =
  ## This computational maneuver could cost us legal fees!
  ## nah, jk, who's gonna go around sueing random idiots? ;)

  when license is string:
    return parseLicense(license) == Proprietary

  when license is License:
    return license == Proprietary
