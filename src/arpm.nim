import
  std/[strutils],
  ./[argparse],
  commands/[
    package_search, repository_ls, im_different, package_install, version, help,
    package_uninstall
  ],
  ./libarpm/[package_list, io]

proc main() =
  let
    args = parseArguments()
    targets = args.getTargets()
    forced = args.isSwitchEnabled("force", "f")
    noConfirm = args.isSwitchEnabled("no-confirm", "y")

  if targets.len < 1:
    help()

  let op = targets[0]

  case op.toLowerAscii()
  of "refresh":
    info "Refreshing package lists"
    discard packageList(refresh = true)

    info "Refreshed package lists!"
  of "search":
    packageSearch(targets[1..targets.len - 1], forced)
  of "repo-ls":
    repositoryLs(forced)
  of "lemonade", "im-different", "combustible-lemons":
    imDifferent()
  of "install":
    install(targets[1..targets.len - 1], forced, noConfirm)
  of "uninstall", "remove":
    uninstall(targets[1..targets.len - 1], forced, noConfirm)
  of "version":
    version(args.getFlag("format"))
  of "help", "whatdoido", "im-stuck", "send-help":
    help()
  else:
    error("Unknown option: " & op, true)

when isMainModule:
  main()
