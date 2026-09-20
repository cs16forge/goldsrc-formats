# Spray logo: `tempdecal.wad`

A Counter-Strike 1.6 / Half-Life spray is an 8-bit paletted picture inside a one-lump **WAD3**
file. This page gives the byte layout, the transparency rule and — the part guides get wrong —
the size rules.

Player-facing version: [How to make and install a spray in CS 1.6](https://cs16forge.com/guides/cs-16-spray-logo/).

## Files involved

| File | Role |
|---|---|
| `cstrike/tempdecal.wad` | **The only file the game reads for your spray.** WAD3 with a single miptex lump named `{LOGO`. The game regenerates it from the logo chosen in the options menu, so a custom file survives only if you stop changing the logo there (many players make the file read-only). |
| `pldecal.wad` | Half-Life's twin name. Converters write a copy "just in case"; CS does not need it. |
| `valve/logos/*.bmp` | stock logos: 8 bpp BMP, 64×64, 256-colour palette. The menu builds the spray from one of these. |
| `cstrike/logos/remapped.bmp` | the chosen logo after the menu's colour remap — an intermediate artefact. |
| `custom.hpk` | HPAK archive of "customizations": your own spray as uploaded, and other players' sprays received from servers. |

On connect the client uploads the spray to the server (`sv_allowupload`, capped by
`sv_uploadmax`); the server validates it and hands it to the other clients, which cache it in
their own `custom.hpk`.

## Byte layout

Little-endian. Example: an 80×80 spray, 9356 bytes.

```
0      WAD3 header, 12 bytes
         char[4] magic      = "WAD3"
         u32     numLumps   = 1
         u32     dirOffset  = 9324

12     miptex lump
         char[16] name      = "{LOGO"            zero-padded; this exact name is expected
         u32      width     = 80
         u32      height    = 80
         u32[4]   mipOffset = 40, 6440, 8040, 8440     from the start of the lump
         u8[]     mip0..3   = 6400 + 1600 + 400 + 100 palette indices
         u16      palCount  = 256
         u8[768]  palette   = 256 x RGB;  palette[255] = (0, 0, 255)
         pad to a multiple of 4                  9310 -> 9312

9324   directory entry, 32 bytes
         u32 filePos = 12     u32 diskSize = 9312     u32 size = 9312
         u8  type    = 0x43 (miptex)     u8 compression = 0     u16 pad
         char[16] name = "{LOGO"
```

**Transparency** works as for any `{`-prefixed GoldSrc texture: **palette index 255 is not
drawn**. By convention that palette entry is pure blue `(0, 0, 255)`. Alpha is binary — there is
no partial transparency. An encoder therefore quantises to **255** colours and reserves the last
index.

## Size rules

Server-side validation is `Draw_ValidateCustomLogo`, called from `CustomDecal_Validate`
([ReHLDS `decals.cpp`](https://github.com/rehlds/ReHLDS/blob/master/rehlds/engine/decals.cpp)):

| Rule | Value | Notes |
|---|---|---|
| side length | 1 … 256 | vanilla limit |
| ReHLDS cap | **64 × 64** when `sv_rehlds_allow_large_sprays 0` | default is `1` (up to 256), but some public servers set `0`. **64×64 is the most compatible size.** |
| mip chain | `mipOffset[i+1] == mipOffset[i] + (w >> i) * (h >> i)` | otherwise rejected. All four mip levels must physically be there. |
| palette | ≤ 256 entries | and the lump's byte count must match `diskSize` |
| side multiple | 8 technically (mip 3 is w/8 × h/8); **16 in practice** | every converter uses a step of 16 |
| **pixel budget** | **w × h ≤ 14336** | largest areas: 112×128 or 128×112 |

About the budget: it is a limit of the client-side customization path, not a field in the file.
The figure is the one converters implement — e.g.
[img2tempdecal](https://github.com/nm004/img2tempdecal) uses `max_limit = 112*128 + 1` with
sides from `16` to `256` in steps of `16`. The folklore "14 KB limit" is this number
misremembered: it counts **pixels, not bytes** — a 112×128 file weighs about 19.4 KB. Other
figures circulate in older guides; we have not seen them backed by source.

All side pairs that fit, for sides that are multiples of 16:

| Height → | 16 | 32 | 48 | 64 | 80 | 96 | 112 | 128 | 144 | 160 … 256 |
|---|---|---|---|---|---|---|---|---|---|---|
| max width | 256 | 256 | 256 | 224 | 176 | 144 | 128 | 112 | 96 | `floor(14336 / h / 16) * 16` |

Largest areas by shape: 112×128 and 224×64 use the whole budget (14336); 176×80 = 14080;
144×96 = 13824; 256×48 = 12288. A square source fits as 112×112.

**Physical size on the wall: 1 texel = 1 world unit.** A player is 72 units tall, so a 112×128
spray is taller than a player. "Big sprays" are literally big.

## Encoder checklist

1. Resize to a legal size (see above); decide between "best quality" and "64×64, works everywhere".
2. Treat alpha < 128 as transparent → index 255.
3. Quantise the opaque pixels to 255 colours (median cut is enough).
4. Build real mip levels. The engine does not seem to care about mip 1–3 content for decals —
   some converters fill them with `0xFF` — but honest mips cost nothing. When downsampling, make a
   texel transparent if most of its sources are.
5. Set `palette[255] = (0, 0, 255)`, pad the lump to 4 bytes, write the directory.

A decoder must use the **strict** key (index 255 only). Heuristics that map-texture viewers use
for `{` textures — treating any blue-ish fringe as transparent — eat legitimate blue pixels in
spray art.

## Verified

| Claim | How |
|---|---|
| byte layout | parsed real community sprays; our encoder reproduces a real 80×80 file's size byte for byte (9356 B) and its pixels exactly |
| validation rules, 64×64 cap | read from ReHLDS source, linked above |
| pixel budget 14336 | taken from converter source; consistent with every working large spray we have; **not** traced to engine source by us |
| 1 texel = 1 unit | engine behaviour, visible in game |

## See also

- [halflife#3094](https://github.com/ValveSoftware/halflife/issues/3094) — when the engine regenerates `tempdecal.wad`
- [TWHL: WAD3 specification](https://twhl.info/wiki/page/Specification:_WAD3)
- [`schemas/wad3.ksy`](schemas/wad3.ksy)

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
