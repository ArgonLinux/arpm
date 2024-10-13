## Input/output module for libarpm and **optionally** all programs that use it.

import std/[rdstdin, colors, strutils]

const
  INFO_COLOR* = "\e[0;32m"
  ERROR_COLOR* = "\e[0;31m"
  WARN_COLOR* = "\e[0;33m"

  # Oh, how the tables have turned.
  GREEN* = INFO_COLOR
  RED* = ERROR_COLOR
  YELLOW* = WARN_COLOR

  BOLD* = "\e[1;37m"
  RESET* = "\e[0m"

proc info*(msg: string) =
  ## Print an informational message.
  stdout.write INFO_COLOR & "INFO" & ' ' & RESET & BOLD & msg & RESET & '\n'

proc error*(msg: string, quits: bool = false) =
  ## Print an error message.
  ##
  ## Optionally, the program can also be forced to quit.
  stdout.write ERROR_COLOR & "ERR" & "  " & RESET & BOLD & msg & RESET & '\n'

  if quits:
    quit(1)

proc warn*(msg: string) =
  ## Print a warning message.
  stdout.write WARN_COLOR & "WARN" & ' ' & RESET & BOLD & msg & RESET & '\n'

proc ask*(
    msg: string,
    options: array[0..1, string],
    retryCount: uint64 = uint64.high,
    caseSensitive: bool = false,
    arpmRetryCount: uint64 = 0'u64,
): int =
  ## Ask a question with two options.
  var
    answer =
      readLineFromStdin(
        YELLOW & " ... " & RESET & BOLD & msg & RESET & " [" & GREEN &
          options[0].toLowerAscii() & RESET & '/' & RED & options[1].toUpperAscii() &
          RESET & "] "
      )

  if not caseSensitive:
    answer = answer.toLowerAscii()

    for i, option in options:
      if toLowerAscii(option) == answer:
        return i

    error("Invalid answer: " & answer)

    if (arpmRetryCount + 1'u64) < retryCount:
      return ask(msg, options, retryCount, caseSensitive, arpmRetryCount + 1'u64)
    else:
      error("Maximum retries exceeded!", true)
  else:
    for i, option in options:
      if option == answer:
        return i

    error("Invalid answer: " & answer)
    if (arpmRetryCount + 1'u64) < retryCount:
      return ask(msg, options, retryCount, caseSensitive, arpmRetryCount + 1'u64)
    else:
      error("Maximum retries exceeded!", true)

proc ask*(msg: string): string {.inline.} =
  ## Ask a question with any arbitrary input
  readLineFromStdin(YELLOW & " ... " & RESET & BOLD & msg & RESET & ": ")

proc confirm*(
    msg: string, retryCount: uint64 = uint64.high, arpmRetryCount: uint64 = 0'u64
): bool =
  ## Confirm an action
  var
    answer =
      readLineFromStdin(
        YELLOW & ".... " & RESET & BOLD & msg & RESET & " [" & GREEN & 'y' & RESET & '/' &
          RED & 'N' & RESET & "] "
      ).toLowerAscii()

  if answer.len > 1:
    # Interpret yes/no/true/false as y/n/y/n
    case answer
    of "yes":
      answer = "y"
    of "no":
      answer = "n"
    of "true":
      answer = "y"
    of "false":
      answer = "n"
    of "maybe":
      error("You're weird. I don't like you.", true)

  answer == "y"
