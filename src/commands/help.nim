import libarpm/io

proc bullet*(msg: string) {.inline.} =
  echo "* " & msg

proc header*(msg: string) {.inline.} =
  echo '\n' & BOLD & msg & RESET

proc usage*(msg: string) {.inline.} =
  echo BOLD & "usage" & RESET & ": " & GREEN & msg & RESET

proc aliases*(aliases: openArray[string]) {.inline.} =
  var s = BOLD & "aliases" & RESET & ": "

  for i, al in aliases:
    s &= GREEN & al & RESET
    
    if i != aliases.len-1:
      s &= ", "

  echo s

proc help* =
  echo """
arpm [options] [targets]

List of Commands:
  refresh                         Refresh package lists.
  search                          Search for a package in the package lists.
  im-different                    Oracle turrets :3
  repo-ls                         List every package in the package lists.
  install                         Install a package.
  version                         Print out arpm's version, with 3 formats (see below).
  help                            Show this message.
"""

  echo "\nUsage"

  header "Refresh"
  usage "arpm refresh"
  bullet "This command takes in no arguments. It just refreshes the package lists, if there's updated versions available."

  header "Search"
  usage "arpm search <package1> <package2> ..."
  bullet "This command takes package names as arguments."

  header "I'm Different!"
  usage "arpm im-different"
  aliases ["lemonade", "combustible-lemons"]
  bullet "Watch a schizophrenic turret ramble, I guess."

  header "List Repository"
  usage "arpm repo-ls"
  bullet "List every package in the package lists."

  header "Install"
  usage "arpm install <package1> <package2> ..."
  bullet "Install a package if it exists."
  bullet "Packages are installed sequentially. If one of the packages fails to install due to any reason, the packages beyond it will not be installed."

  header "Version"
  usage "arpm version --format=<format>"
  echo "`format` can be empty, or: "
  bullet "json: prints out a JSON-encoded string, useful for scripts."
  bullet "arpm_ver: just prints out arpm's version, nothing else."

  header "Help"
  usage "arpm help"
  aliases ["whatdoido", "im-stuck", "send-help"]
  bullet "This won't send a 60-year-old Slackware user who still uses floppy disks to come to your home to fix all your issues. You'll still have to RTFM."

  quit(0)
