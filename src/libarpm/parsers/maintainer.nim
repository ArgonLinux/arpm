import std/[strutils], ../io

type
  ## Contact addresses for a maintainer.
  ## All of them are optional.
  Contacts* = object
    github*, mastodon*, email*, gitlab*: string

  ## A maintainer's data.
  Maintainer* = object
    real_name*: string ## The maintainer's real name
    contacts*: Contacts ## The maintainer's contacts

proc `$`*(maintainer: Maintainer): string =
  result &= YELLOW & maintainer.realName & RESET

  if maintainer.contacts.github.len > 0:
    result &=
      "\n\t* " & GREEN & "GitHub: " & RESET & BOLD & maintainer.contacts.github & RESET

  if maintainer.contacts.mastodon.len > 0:
    result &=
      "\n\t* " & GREEN & "Mastodon: " & RESET & BOLD & maintainer.contacts.mastodon &
      RESET

  if maintainer.contacts.email.len > 0:
    result &=
      "\n\t* " & GREEN & "E-Mail: " & RESET & BOLD & maintainer.contacts.email & RESET

  if maintainer.contacts.gitlab.len > 0:
    result &=
      "\n\t* " & GREEN & "Gitlab: " & RESET & BOLD & maintainer.contacts.gitlab & RESET

proc `=destroy`*(contacts: Contacts) =
  `=destroy`(contacts.github)
  `=destroy`(contacts.mastodon)
  `=destroy`(contacts.email)
  `=destroy`(contacts.gitlab)

proc `=sink`*(dest: var Contacts, src: Contacts) =
  wasMoved(dest)

  dest.github = src.github
  dest.mastodon = src.mastodon
  dest.email = src.email
  dest.gitlab = src.gitlab

  `=destroy`(src)

proc `=destroy`*(maintainer: Maintainer) =
  `=destroy`(maintainer.realName)
  `=destroy`(maintainer.contacts)

proc `=sink`*(dest: var Maintainer, src: Maintainer) =
  wasMoved(dest)

  dest.realName = src.realName
  dest.contacts = src.contacts

  `=destroy`(src)

proc parseMaintainer*(mStr: string): Maintainer =
  ## Parse a maintainer from a Argon maintainer "spec-compliant" string.
  ## <real name> (<contact_form_1>:<contact_address_1>,<contact_form_2>:<contact_address_2>) and so on, and so forth.
  ##
  ## Currently, only GitHub, Mastodon, Email and GitLab are supported.
  var
    curr: char
    pos: int

    realName: string
    contacts = Contacts()

    cContactMeth: string
    cContactMethDone: bool

  while curr != '(':
    curr = mStr[pos]

    # well, this is stupid.
    if curr == '(':
      inc pos
      realName = realName[0..realName.len - 2]
      break

    realName &= curr

    if pos >= mStr.len:
      error(
        "While parsing maintainer string: expected atleast 1 contact source, got EOF.",
        true
      )

    inc pos

  while curr != ')':
    curr = mStr[pos]

    # this too, is fairly asanine.
    if curr == ')':
      inc pos
      break

    if curr == ':':
      if cContactMeth.len < 1:
        error("While parsing contact: got no method name, got '@' instead.", true)

      cContactMeth = toLowerAscii(cContactMeth)
      cContactMethDone = true
      inc pos
      continue

    if curr == ',':
      reset cContactMethDone
      reset cContactMeth
      inc pos
      continue

    if not cContactMethDone:
      cContactMeth &= curr
    else:
      case cContactMeth
      of "gh", "github":
        contacts.github &= curr
      of "gl", "gitlab":
        contacts.gitlab &= curr
      of "email", "mail":
        contacts.email &= curr
      of "mstdn", "mastodon", "fedi":
        contacts.mastodon &= curr
      else:
        error("While parsing contact: invalid contact method: " & cContactMeth, true)

    inc pos

  Maintainer(realName: realName, contacts: contacts)
