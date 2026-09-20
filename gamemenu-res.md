# Main menu: `GameMenu.res`

`cstrike/resource/GameMenu.res` defines the items of the Counter-Strike 1.6 main menu. It works
the same way on the Steam version and on non-Steam clients, which makes it the most portable way
to give a player a **one-click "connect to my server" button**.

> A note on reputation: this file is also what malicious servers used to overwrite through
> "slowhack" command injection, to plant their own buttons. Everything here is about a player (or
> a build author) editing **their own** file. If your menu has buttons you did not add, restoring
> the stock file below is the fix.

## Grammar

Valve KeyValues. One root block, numbered child blocks, each child is a menu item:

```
"GameMenu"
{
	"1"
	{
		"label"      "#GameUI_GameMenu_ResumeGame"
		"command"    "ResumeGame"
		"OnlyInGame" "1"
	}
	"2"
	{
		"label"   ""
		"command" ""
	}
	...
}
```

| Key | Meaning |
|---|---|
| `label` | text shown. A value starting with `#` is a localisation token looked up in `resource/gameui_*.txt` |
| `command` | what the item does — a GameUI command or `engine <console command>` |
| `OnlyInGame` `"1"` | shown only while connected / in a game |
| `notsingle` `"1"` | hidden in single-player |

An item with **empty `label` and empty `command` is a spacer**.

**Order on screen = order in the file.** The numeric block names are just names: you may renumber
them freely, and tools that insert items should renumber the whole list rather than hunt for a
free number.

## Stock commands

| `command` | Item |
|---|---|
| `ResumeGame` | Resume game |
| `Disconnect` | Disconnect |
| `OpenPlayerListDialog` | Player list |
| `OpenCreateMultiplayerGameDialog` | New game |
| `OpenServerBrowser` | Find servers |
| `OpenOptionsDialog` | Options |
| `OpenHelpUrl` | Help |
| `ConnectToRandomServer` | Random server (present in some clients' stock file) |
| `Quit` | Quit |
| `engine <cmd>` | run a console command, e.g. `engine connect 192.0.2.10:27015` |

## A "connect" button

```
	"5"
	{
		"label"   "My server"
		"command" "engine connect 192.0.2.10:27015"
	}
	"6"
	{
		"label"   ""
		"command" ""
	}
```

Place it above "New game" and follow it with a spacer.

## Pitfalls

- **Label characters.** `"`, `\`, `{`, `}`, tabs and line breaks break KeyValues parsing — strip
  them. A **leading `#`** turns the label into a localisation token, and an unknown token shows
  up as the raw `#text`; strip leading `#` too.
- **Encoding.** Stock `.res` files are sometimes UTF-16 LE with a BOM. A reader must handle both
  UTF-16 (BOM `FF FE`) and UTF-8 (optional BOM `EF BB BF`). Writing plain UTF-8 works, including
  Cyrillic labels — community builds ship such files.
- **Vertical room.** The menu does not scroll. On a 768-pixel-high screen roughly three extra
  items fit above "New game" before the list runs off the top.

## Verified

Grammar, flags and stock commands — read from stock files of the Steam version and of non-Steam
clients. `engine connect …` buttons are common in community builds and work in game. The "three
extra items at 768 px" figure is from our own layout check and depends on the client's menu skin.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
