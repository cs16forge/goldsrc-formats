# VGUI colour schemes: `ClientScheme.res` and `TrackerScheme.res`

What recolours the menus and dialogs of Counter-Strike 1.6, how the files are built, and the two
different places a scheme can be installed.

You can preview and install schemes — and see which one your game uses right now — in the
[cs16forge Workshop](https://cs16forge.com/workshop/).

## Two files, two jobs

| File | Paints |
|---|---|
| `cstrike/resource/ClientScheme.res` | in-game VGUI: team/class selection, buy menu, scoreboard, MOTD |
| `cstrike/resource/TrackerScheme.res` | GameUI: main menu, options, server browser, create-server dialog |

Both are Valve KeyValues with the same top-level anatomy:

```
Scheme
{
	Colors        { ... }     named colours
	BaseSettings  { ... }     what each control uses — values are colours or names from Colors
	Fonts         { ... }
	Borders       { ... }
}
```

A colour is `"R G B A"` (0–255 each). A `BaseSettings` value is either such a literal or the
**name** of an entry in `Colors`:

```
Colors        { "OffWhite" "216 216 216 255"   "TransparentBlack" "0 0 0 128" }
BaseSettings  { Button.TextColor "OffWhite"    Button.BgColor "76 88 68 255" }
```

To resolve a control's colour: read the `BaseSettings` key; if it is not four numbers, look it up
in `Colors`.

## Two key dialects

Schemes in the wild are written in one of two vocabularies, and a reader has to support both:

| | Classic | Dotted |
|---|---|---|
| Looks like | flat keys plus nested blocks: `"FgColor"`, `"BgColor"`, `"TitleBarBgColor"`, `Menu { "ArmedBgColor" … }`, `Slider { … }` | one flat list of `Control.Property` keys: `Button.TextColor`, `Frame.BgColor`, `CheckButton.Border1` |
| Named colours | role-like: `ControlBG`, `ControlText`, `SelectionBG`, `BorderDark` | paint-like: `White`, `OffWhite`, `TransparentBlack` |
| Seen in | stock `ClientScheme.res`, most community schemes | stock `TrackerScheme.res` of current builds |

**The dialect and the install slot are independent.** A scheme written in the classic vocabulary
may be meant for the GameUI slot and vice versa. Detect the dialect from the content (for example,
"is there a `Frame.BgColor` key?"), never from the file name or from where the pack says to put it.

## Two install slots

| Slot | Files touched | Works on |
|---|---|---|
| A | replace `cstrike/resource/ClientScheme.res` | every client, including the Steam version |
| B | put the scheme at `cstrike/resource/schemes/TrackerScheme_Custom.res` **and** set the `"Scheme"` key in `cstrike/MiscellaneousSettings.vdf` to point at it | [NextClient](https://github.com/CS-NextClient/NextClient) |

For slot B:

- **Edit the `.vdf` surgically** — change only the `"Scheme"` line. The file also holds the
  player's other settings; rewriting it from a template destroys them.
- **Order matters.** Install: write the scheme file first, then point the `.vdf` at it. Uninstall:
  reset the pointer first, then delete the file. The other order leaves a window where the client
  is told to load a file that is not there.

## KeyValues quirks that bite in `.res` files

- `//` starts a comment — **except inside quotes** (URLs survive).
- Keys and values may be quoted or bare tokens (`Button.TextColor "White"` is typical).
- **Backslash is not an escape character here.** `.res` files use it as a path separator;
  treating `\"` or `\\` as escapes corrupts them.
- Duplicate keys: the last one wins.
- Files may be UTF-16 LE with a BOM. Detect it.
- Paths inside are case-insensitive on Windows; if you index files by name, lower-case the keys
  (`TrackerScheme_Custom.res` will not be found under its mixed-case name otherwise).

## Verified

Anatomy and both dialects — read from stock files and from several hundred community scheme files;
most of them use the classic vocabulary. Slot A works on every client
we tried. Slot B install/uninstall order was worked out in game on NextClient.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
