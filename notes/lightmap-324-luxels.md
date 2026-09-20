# Lightmap limit: 18 × 18 = 324 luxels per face

**Fact.** A GoldSrc face gets one lightmap sample (luxel) per **16 texels** along each texture
axis, and the renderer refuses a face whose lightmap is larger than **18 × 18 = 324** luxels
(the in-game error names the texture and says the lightmap "cannot exceed 324"). An older,
slightly tighter bound also exists: texture-space extents above 256 give "Bad surface extents".

**The trap: extents are measured in texels, not in world units.** They come from projecting the
face's vertices through its `texinfo` vectors. So the limit depends on how much *texture* the
face spans:

- a poster whose 512×384 image is mapped exactly once onto a quad spans 512×384 texels
  → 33 × 25 luxels → rejected — **however small the quad is in the world**;
- the same quad with a tiling 64×64 texture is fine.

**What to do.** Split the face **in texture space**: keep each piece at or under 240 texels per
axis (≤ 16 luxels, safe for both bounds).

**What not to do.** Do not clamp the lightmap size when you allocate lighting data. The engine
recomputes extents from the geometry itself; a clamped lightmap will not match what it expects.

**Verified** in game (CS 1.6): a single 512×384 face produced the error; the same picture split
into pieces of at most 240 texels rendered correctly.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
