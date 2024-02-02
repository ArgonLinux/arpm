import std/algorithm

proc levenshteinDist*(a, b: string): int =
  var res = 0

  if a == b:
    return res

  let
    lA = a.len
    lB = b.len

  if lA == 0:
    return lB

  if lB == 0:
    return lA

  var
    cache: seq[int] = newSeq[int](lA)
    distA, distB: int

  for iB, cB in b:
    res = iB
    distA = iB

    for iA, cA in a:
      distB =
        if cA == cB:
          distA
        else:
          distB + 1

      distA = cache[iA]

      res =
        if distA > res:
          if distB > res:
            res + 1
          else:
            distB
        elif distB > distA:
          distA + 1
        else:
          distB

      cache[iA] = res

  res

type
  ComparisonAlgorithm* = enum
    caLevenshtein

proc search*(
    part: string,
    strings: openArray[string],
    maxDst: int = 10,
    algo: ComparisonAlgorithm = caLevenshtein,
): seq[string] =
  var res: seq[tuple[a: string, b: int]]

  for s in strings:
    let
      dst =
        case algo
        of caLevenshtein:
          levenshteinDist(part, s)

    if dst <= maxDst:
      res.add((a: s, b: dst))

  res.sort(
    proc(x, y: tuple[a: string, b: int]): int {.closure.} =
        cmp(x.b, y.b)
  )

  for item in res:
    result.add(item.a)
