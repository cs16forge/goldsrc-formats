# Weapon inspect animations: sequence indices

Counter-Strike 1.6 has no "inspect weapon" action. [NextClient](https://github.com/CS-NextClient/NextClient)
adds one, and the contract between the client and a `v_` (view) model is nothing but a
**hard-coded sequence index per weapon**. A skin "supports inspect" if, and only if, it has a
sequence at that index.

Skins with a working inspect animation are marked in the [cs16forge skins catalogue](https://cs16forge.com/skins/).

## The table

Zero-based sequence index that the client plays on "inspect":

| Weapon | Index | | Weapon | Index | | Weapon | Index |
|---|---|---|---|---|---|---|---|
| ak47 | 6 | | g3sg1 | 5 | | p228 | 7 |
| aug | 6 | | galil | 6 | | p90 | 6 |
| awp | 6 | | glock18 | 13 | | scout | 5 |
| deagle | 6 | | knife | 8 | | sg550 | 5 |
| elite | 16 | | m249 | 5 | | sg552 | 6 |
| famas | 6 | | m3 | 7 | | tmp | 6 |
| fiveseven | 6 | | **m4a1** | **14 / 15** | | ump45 | 6 |
| mac10 | 6 | | mp5navy | 6 | | **usp** | **16 / 17** |
| xm1014 | 7 | | | | | | |

No inspect: HE grenade, flashbang, smoke grenade, C4, shield.

In every case the index equals the **number of sequences in the stock model** — the inspect
animation is simply the next sequence after the stock set. Source:
[`client_mini/src/inspect.cpp`](https://github.com/CS-NextClient/NextClient/blob/main/nextclient/client_mini/src/inspect.cpp)
(`inspectAnims[]`, indexed by weapon id).

## The two-sequence weapons

`m4a1` and `usp` have a silencer state, so they need **two** inspect sequences:

| Weapon | Silenced | Unsilenced |
|---|---|---|
| m4a1 | 14 | 15 |
| usp | 16 | 17 |

The client picks the second one when the current sequence is at or past the weapon's
unsilenced-idle index (`M4A1_UNSIL_IDLE` = 7, `USP_UNSIL_IDLE` = 8). A model with only the first
sequence will play the silenced inspect on an unsilenced gun.

## What the client does *not* check

- **Sequence names.** `inspect`, `lookat`, anything — irrelevant.
- **FPS and frame count.** Duration is computed as `numframes / fps` from the sequence itself.
- **Whether it looks like an inspect.** Any sequence at the index is played.

Consequences for tool authors:

- "Has inspect" is a purely structural test: `numseq > index` (and `> index + 1` for m4a1/usp).
- It over-reports. Models whose extra sequence is a copy of idle, or a nearly motionless loop,
  pass the test and do nothing visible when the player presses the key.
- Many CS:GO ports bake the inspect into a **long idle** (an idle of 200+ frames whose second half
  is the inspect). They have no sequence at the inspect index, so the client never plays it on
  demand — the player just sees the gun being examined at random.
- If you add a sequence to a `.mdl`, insert it properly: see
  [Do not append to a `.mdl`](notes/mdl-texturedataindex-trap.md).

## Verified

Table compared entry by entry with the public NextClient source linked above, and in game on
models of several weapon slots, including both two-sequence weapons.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
