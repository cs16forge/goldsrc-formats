# What `dev_overview` actually draws

Counter-Strike overview images (`overviews/<map>.bmp` + `.txt`, used by the radar and the
spectator view) are screenshots of the engine's `dev_overview` mode. There is no clever roof
removal in it.

Maps with overviews: [cs16forge.com/maps](https://cs16forge.com/maps/). Radar settings for players:
[guide](https://cs16forge.com/guides/cs-16-radar-settings/).

## The algorithm

Readable in the GoldSrc-compatible [Xash3D FWGS](https://github.com/FWGS/xash3d-fwgs) engine:

| Step | Where |
|---|---|
| Orthographic camera looking straight down; view rectangle `8192 / zoom` wide, 4:3 | `engine/client/cl_view.c`, `V_RefApplyOverview` |
| Defaults: near plane at the top of the world, far plane at the bottom, zoom from the world's bounding box, origin at its centre | `engine/client/cl_main.c`, `CL_SetupOverviewParams` |
| The mapper then moves the near/far planes, zoom and origin with keys | `CL_ProcessOverviewCmds` |
| Background is pure green `(0, 255, 0)` — the transparency key of the BMP | `ref/gl/gl_rmain.c` |
| The world is walked without VIS; **only faces whose normal points up** are drawn | `ref/gl/gl_rsurf.c` `R_DrawWorldTopView`, `gl_cull.c` |
| The `.txt` stores `ZOOM`, `ORIGIN`, `ROTATED` and one `HEIGHT` = the far plane | `engine/client/cl_scrn.c`, `VID_WriteOverviewScript` |

So an overview is **one horizontal slab of up-facing world faces**. Roofs disappear only because
the mapper lowered the near plane below them. On multi-level maps that cannot work everywhere,
and some stock overviews were visibly touched up by hand.

## Frame geometry

The image covers `2 * (4096 / ZOOM)` by `1.5 * (4096 / ZOOM)` world units around `ORIGIN`.
`ROTATED 0` and `ROTATED 1` differ by a quarter turn; there is no mirroring.

## A caveat

Xash3D is a reimplementation. Its `dev_overview` output is close to, but not identical with, the
stock Valve overview images, and no open implementation of GoldSrc's own renderer exists to settle
the differences from code: ReHLDS is a dedicated server and only precaches the overview files.
Treat the stock images as the ground truth.

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
