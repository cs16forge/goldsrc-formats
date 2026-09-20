# HUD sprites: `hud.txt`, `weapon_*.txt` and `.spr`

How the Counter-Strike 1.6 HUD is assembled from sprite sheets, what a "HUD pack" really
replaces, and what to check before shipping one.

Player-facing: [HUD packs](https://cs16forge.com/hud/) · [How to change the HUD in CS 1.6](https://cs16forge.com/guides/cs-16-change-hud/).

## 1. Elements are looked up by name

The client has a fixed set of HUD **elements** — digits, the health cross, the radar, kill-feed
icons. It never hard-codes image paths; it asks for an element *by name* through text manifests in
`cstrike/sprites/`.

### `sprites/hud.txt`

```
215
number_0   640  640hud7   0    0   20  25
cross      640  640hud7   48   25  24  24
radar      640  radar640  0    0   128 128
d_ak47     640  640hud1   192  80  48  16
```

First line: declared entry count (215 in stock CS 1.6). Then one entry per line:

| Column | Meaning |
|---|---|
| name | element name the client asks for |
| resolution | `320` or `640` |
| sprite | file `sprites/<sprite>.spr`, **without extension** |
| x y w h | rectangle inside that sprite's frame |

Separators are runs of spaces/tabs; `//` starts a comment. Every name appears twice: a `320` set
(screens narrower than 640) and a `640` set (everything modern). The engine takes entries for its
resolution and falls back to `320` when a `640` entry is missing. Sprite files resolve through the
usual search path — mod folder first, then `valve/` (`crosshairs.spr` exists only in `valve/`).

Stock element groups (all are cut-outs of the 256×256 atlases `640hud1..20.spr`):

| Group | Elements | Atlas |
|---|---|---|
| digits | `number_0..9`, `divider`, `dollar`, `minus`, `plus` | 640hud7 |
| status | `cross` (health), `suit*` (armour), `flash_*`, `stopwatch` | 640hud7 |
| scenario icons | `c4`, `defuser`, `buyzone`, `rescue`, `escape`, `vipsafety`, `hostage*`, `bombticking*` | 640hud7 |
| kill feed | `d_knife`, `d_ak47`, … `d_headshot`, `d_skull` | 640hud1 / 2 / 16 |
| damage | `dmg_bio`, `dmg_cold`, `dmg_heat`, `dmg_gas`, `dmg_rad`, `dmg_shock`, `dmg_drown`, `dmg_chem` | 640hud8 / 9 |
| radar | `radar` → `radar640.spr`, `radaropaque` → `radaropaque640.spr` | own files |
| Half-Life leftovers | `train_*`, `title_*`, `item_*`, `autoaim_c`, `selection` | 640hud3..6, crosshairs |

### `sprites/weapon_<name>.txt`

Same line format, one file per weapon (33 in stock `cstrike/`), loaded when the weapon is handed
to the player. Five elements per resolution, seven for scoped rifles:

```
weapon        640  640hud2       0   135  170  45     weapon-select picture
weapon_s      640  640hud5       0   135  170  45     same, highlighted
ammo          640  640hud7       24  96   24   24     ammo icon
crosshair     640  crosshairs    24  0    24   24     Half-Life legacy (see below)
autoaim       640  crosshairs    0   72   24   24
zoom          640  sniper_scope  0   0    256  256    awp / scout / g3sg1 / sg550 only
zoom_autoaim  640  sniper_scope  0   0    256  256
```

A `weapon_*.txt` whose name matches no weapon on the server is simply never read.

### What is *not* a sprite

- **The normal crosshair is drawn procedurally with lines** (`cl_crosshair_*` cvars). A "custom
  crosshair" for ordinary weapons is a config change, not a file. The `crosshair` entries above
  are Half-Life legacy.
- **The black circle of the sniper scope is not a sprite.** It is four quarter arcs —
  `scope_arc.tga`, `scope_arc_ne.tga`, `scope_arc_nw.tga`, `scope_arc_sw.tga`, 256×256 each — tiling
  a 512×512 square; the rest of the screen is filled with black bars. `sniper_scope.spr` carries
  only the thin lines and ticks, stretched over a square the height of the screen.
- Radar has two sprites: `radar640.spr` (additive, translucent) and `radaropaque640.spr`
  (alpha-tested, opaque), switched by `cl_radartype 1`.

## 2. `.spr` — IDSP version 2

Little-endian. 42-byte header, palette, frames.

| Field | Type | Values |
|---|---|---|
| magic | char[4] | `IDSP` |
| version | i32 | **2** = GoldSrc. (1 = Quake: no palette; GoldSrc will not load it.) |
| type | i32 | world orientation: 0 `VP_PARALLEL_UPRIGHT`, 1 `FACING_UPRIGHT`, 2 `VP_PARALLEL`, 3 `ORIENTED`, 4 `VP_PARALLEL_ORIENTED` |
| texFormat | i32 | 0 `NORMAL`, 1 `ADDITIVE`, 2 `INDEXALPHA`, 3 `ALPHATEST` |
| boundingRadius | f32 | for culling world sprites |
| maxWidth, maxHeight | i32 × 2 | bounding size; frames may be smaller |
| numFrames | i32 | |
| beamLength | f32 | unused |
| syncType | i32 | 0 synchronised, 1 random |
| paletteCount | **i16** | 256 |
| palette | u8[256 × 3] | RGB |

Then `numFrames` frames. Each starts with an i32 **frame type**: `0` = single frame; otherwise a
**group**: i32 count, `count` × f32 intervals (seconds), then `count` frames. A frame is
`originX, originY, width, height` (i32 × 4) followed by `width * height` palette indices.

How `texFormat` renders:

| texFormat | Rendering |
|---|---|
| `NORMAL` | opaque, palette as is |
| `ADDITIVE` | pixels are **added** to the background, so black is invisible. Every stock HUD atlas is additive, and the engine **tints it with the HUD colour** (yellow; red under 25 HP). That is why HUD art is drawn white/grey. |
| `INDEXALPHA` | colour = `palette[255]`, alpha = the index itself (glows, smoke) |
| `ALPHATEST` | index 255 transparent, everything else opaque (scopes, the opaque radar) |

Survey of 503 `.spr` files (stock `cstrike/` and `valve/`, plus sprites shipped inside community
maps): all version 2; palette always 256; **no grouped frames found** (legal, just unused);
146 multi-frame files, all of them effects — HUD atlases are single-frame; 6 files carry 1–2 bytes
of padding after the last frame (harmless).

## 3. What a "HUD pack" really is

- A pack is a set of `sprites/*.spr` (± `hud.txt`, ± `weapon_*.txt`) that overrides stock **by
  file name**. Builds usually ship a *complete copy* of `sprites/`; the real content is the files
  that **differ byte-wise from stock**. In one popular build, 4 of 105 files differ: the two
  radars, the opaque radar and the sniper scope.
- The most common customisation is a single scope: replacing `sniper_scope.spr`, optionally
  `ch_sniper*.spr`.
- A custom `hud.txt` (different rectangles, different atlases) is rare but legal; such a pack must
  bring its own atlases.
- Sprites shipped with *maps* (timers, flames, grass) are world sprites, not HUD.

## 4. Validation checklist

1. **File.** Magic `IDSP`; `version == 2`; `paletteCount == 256`; every frame reads fully inside
   the buffer (a short file is a broken upload); more than ~16 trailing bytes is suspicious.
2. **Size.** Stock never exceeds 256×256; an atlas over 512×512 is almost certainly not for
   CS 1.6. `w * h == 0` is an error.
3. **Pack completeness.** With a `hud.txt`: every entry's sprite must exist (in the pack or in
   stock `cstrike/`/`valve/`); its rectangle must lie inside the parsed frame (`x + w ≤ width`,
   `y + h ≤ height`); each name should have both `320` and `640` entries — a missing `640` entry
   makes the element vanish on modern resolutions. Without a `hud.txt`: `.spr` names must match
   stock names, or the engine will never open them.
4. **texFormat by role.** Atlases referenced by digit/icon elements must be `ADDITIVE` — a `NORMAL`
   atlas cannot be tinted and paints solid rectangles over the HUD. `zoom` sprites: `ALPHATEST`.
5. **Scope.** Remember the black circle is `scope_arc*.tga` — plain TGAs, validated separately.

## Verified

Formats parsed on the 503-file survey above with a parser that fails loudly; rendering rules
checked by rebuilding the in-game HUD from the sprites and comparing with screenshots.

See also: [TWHL — hud.txt and weapon_*.txt](https://twhl.info/wiki/page/hud.txt_and_weapon_*.txt) ·
[`schemas/spr_goldsrc.ksy`](schemas/spr_goldsrc.ksy)

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
