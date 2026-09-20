# Menu background: TGA tiles and `BackgroundLayout.txt`

The main-menu picture of Counter-Strike 1.6 / Half-Life is a grid of TGA tiles placed by a small
text file. Everything you need to read or build one is below.

Ready-made packs: [cs16forge.com/backgrounds](https://cs16forge.com/backgrounds/) ·
guide: [How to change the menu background in CS 1.6](https://cs16forge.com/guides/how-to-change-menu-background-cs-16/).

## The short version

**Where the engine looks**

1. Stock `cstrike/resource/` has **no layout file** — only 12 tiles,
   `resource/background/800_<row>_<a..d>_loading.tga`.
2. The layout is read from **`valve/resource/`**.
3. Tile paths resolve **`cstrike/` first, then `valve/`**. Half-Life ships tiles with the same
   names, so a tile missing from `cstrike/` silently becomes a piece of the Half-Life picture.
4. Two layouts: `BackgroundLayout.txt` (menu) and `BackgroundLoadingLayout.txt` (start-up and
   loading screen). A pack that ships only the first one makes the Half-Life background flash at
   start-up.

**`BackgroundLayout.txt`** — line-based, *not* KeyValues:

```
resolution	800	600
resource/background/800_1_a_loading.tga		scaled		0	0
resource/background/800_1_b_loading.tga		scaled		256	0
```

`resolution W H` opens a block; each following line is `path  mode  x  y` in frame pixels.
One file may hold several `resolution` blocks.

**Tiles** — 256 px grid; right and bottom edge tiles are smaller and **not padded**
(stock 800×600: columns 256/256/256/**32**, rows 256/256/**88**). The real frame size is the sum
of the tiles, not the number in the file name.

**TGA** — type 2 (uncompressed truecolor), 24 bpp, B-G-R order, rows **bottom-up**, descriptor 0.
Stock header: `00 00 02 00 00 00 00 00 00 00 00 00 00 01 00 01 18 00`.

**Widescreen** — the frame is stretched to the screen; a 4:3 picture is 33 % wider on 16:9.

A companion library and CLI (slice an image into tiles, stitch tiles back, zero dependencies) is
on the way; this page is the specification it implements.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
