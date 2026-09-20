# Embedded vs WAD textures in a BSP: how to tell

**Fact.** Every entry of a BSP30 texture lump is a `miptex` header (name, width, height, four mip
offsets). Whether the pixels are in the map or in an external WAD is decided by that header:

- **mip offsets are zero → no pixels here**; the engine looks the name up in the WADs listed in
  the `wad` key of `worldspawn`;
- mip offsets non-zero → pixels and a palette follow; the texture is embedded.

The test is `mipOffset[0] == 0` **inside the miptex**. It is *not* an offset of −1 in the lump's
own directory — that means "unused slot", a different thing.

**Numbers.** Stock maps embed little: one Valve CS map carries pixels for 15 of its 44 textures.
Across 650 community maps, 73 % embed at least some textures.

**Verified** by parsing the texture lumps of stock and community maps.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
