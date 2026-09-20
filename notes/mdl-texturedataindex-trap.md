# Do not append data to the end of a GoldSrc `.mdl`

**Fact.** After the engine has uploaded a model's textures, it keeps in memory only the part of
the file **before `texturedataindex`** — the pixel data at the end of the file is released.
Anything appended *after* the texture data goes with it. The model loads, and the game crashes the
first time the engine follows an offset into the appended block.

This bites tools that add an animation, an attachment or a hitbox by "writing the new block at the
end and pointing an offset at it" — a technique that is fine for many other formats.

**What to do instead.** Insert the new block where blocks of its kind live inside the file and
shift every absolute offset that points past the insertion — there are many, across the header,
the texture table, the bodypart chain and the sequences.

**Verified** in game (CS 1.6): a model with a sequence appended after the texture data crashed;
the same data placed before the texture data worked.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
