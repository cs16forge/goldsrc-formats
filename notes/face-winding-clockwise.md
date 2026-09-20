# Face winding in BSP30 is clockwise

**Fact.** In a GoldSrc BSP (version 30) the vertices of a face, walked through its surfedges, go
**clockwise when seen from the front side**. Equivalently: `cross(v1 - v0, v2 - v0)` points
*against* the face's visible normal (the plane normal, flipped when `side != 0`).

**Measured.** On a stock Valve map, 5380 of 5383 faces follow the rule.

**Why it matters.** If you write a face into a compiled BSP with counter-clockwise winding, the
engine treats it as back-facing and draws **nothing** — no error, no warning.

**Why you will not notice.** Most BSP viewers, including ones you write yourself, render faces
double-sided. A wrongly wound face looks perfect there, so a "write it, read it back with my own
parser" round trip passes by construction. The only real tests are the game itself, or comparing
your winding with faces the compiler produced.

**A bisect that finds this class of bug quickly**

1. Replace the *pixels* of an existing texture. Visible in game → your miptex, palette and mips
   are fine.
2. Rewrite the *geometry* of an **existing** face (one that is already in a node and in
   marksurfaces). Invisible → the problem is vertices or winding, not the wrapping you built
   around a new face (model, leaf, entity).

**Verified** in game (CS 1.6): the same quad, invisible with counter-clockwise winding, appeared
after reversing the vertex order.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
