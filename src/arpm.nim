import std/[strutils], 
       ./[argparse], 
       commands/[package_search, repository_ls, im_different], 
       libarpm/[package_list, io]

proc main =
  let 
    args = parseArguments()
    targets = args.getTargets()
    forced = args.isSwitchEnabled("force", "f")
    op = targets[0]

  case op.toLowerAscii():
    of "refresh":
      info "Refreshing package lists"
      discard packageList(refresh=forced)

      info "Refreshed package lists!"
    of "search":
      packageSearch(targets[1..targets.len-1], forced)
    of "repo-ls":
      repositoryLs(forced)
    of "lemonade", "im-different", "combustible-lemons":
      imDifferent()
    else:
      error("Unknown option: " & op, true)

when isMainModule:
  main()
