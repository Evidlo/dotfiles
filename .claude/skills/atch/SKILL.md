---
name: atch session attach skill
description: Read from and manipulate atch virtual ttys to help user debug coding sessions
---

- you will primarily use these atch commands:
    - list sessions: `atch list`
    - read last 5 lines from a session: `atch tail -n 5 [session]`
    - send content into session: `atch push [session]`

- and if the user asks you to create your own atch session, you can use the create/start/push commands and the user can attach to inspect


Atch usage help

```
Usage:
  atch [<session> [command...]]		Attach to session or create it
  atch <command> [options] ...

Commands:
  attach  <session>			Strict attach (fail if session missing)
  new     <session> [command...]	Create session and attach
  start   <session> [command...]	Create session, detached
  run     <session> [command...]	Create session, master in foreground
  push    <session>			Pipe stdin into session
  kill    [-f] <session>		Stop session (SIGTERM then SIGKILL)
    -f, --force			Skip grace period, send SIGKILL immediately
  clear   [<session>]			Truncate the session log
  tail    [-f] [-n N] <session>	Print last N lines of session log
    -f				Follow log output
    -n <lines>			Number of lines (default 10)
  list					List all sessions
  current				Print current session name

Options:
  -e <char>	Set detach character (default: ^\)
  -E		Disable detach character
  -r <method>	Redraw method: none | ctrl_l | winch
  -R <method>	Clear method:  none | move
  -z		Disable suspend key
  -q		Suppress messages
  -t		Disable VT100 assumptions
  -C <size>	Log cap: 0=disable, e.g. 128k, 4m (default 1m)

URL: https://github.com/mobydeck/atch
```
