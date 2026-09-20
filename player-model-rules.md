# Player models: why the server kicks you

"I installed a player model and now I get kicked" has **two unrelated causes** in Counter-Strike
1.6. They look the same to the player and need different fixes.

Player-facing version: [Why CS 1.6 kicks you for a player model](https://cs16forge.com/guides/why-cs-16-kicks-for-player-model/).
Bounds are checked in the browser, on your own files, in the [cs16forge Workshop](https://cs16forge.com/workshop/).

| | Cause 1 — external textures | Cause 2 — bounds |
|---|---|---|
| What is wrong | textures live in a companion `<name>T.mdl` **and** one of them has a side not divisible by 16 | the model's geometry sticks out of a fixed box |
| Where it fails | everywhere, **including your own listen server** | servers that enforce file consistency |
| How common | uncommon; 17 of the 711 model resources in our catalogue, all of them player models | rare; 13 of 711 — oversized characters (robots, mechs) |
| Fix | re-compile with textures inside the main `.mdl`, or resize textures to multiples of 16 | none short of re-modelling; use the model offline |

## Cause 1 — external textures with odd sizes

A GoldSrc model may keep its textures in a second file: `numtextures == 0` in the main
`studiohdr_t`, textures in `<name>T.mdl` next to it.

- External textures **alone are fine**. We have player models with a `T.mdl` whose textures are
  all multiples of 16, and they work.
- Odd-sized textures **alone are fine** too — when they are *inside* the main file the engine
  resamples them on load. Hundreds of working weapon skins have such textures.
- The **combination** fails: external `T.mdl` **and** at least one texture with a width or height
  not divisible by 16 (we have seen 252×248). The model does not get into the game even on a
  local server.

So the check is: `numtextures == 0` → open `<name>T.mdl` → any `width % 16 || height % 16` → flag.
"Has external textures" on its own over-reports; "has an odd texture" on its own flags hundreds of
healthy models.

## Cause 2 — the bounds envelope

Under file consistency the game DLL registers player models as **`force_model_specifybounds`**
with the box

```
mins = (-38, -24, -41)      maxs = (38, 24, 41)
```

([ReGameDLL_CS `dlls/client.cpp`](https://github.com/rehlds/ReGameDLL_CS/blob/master/regamedll/dlls/client.cpp)).
The server compares it with what the client reports in
[ReHLDS `SV_ParseConsistencyResponse`](https://github.com/rehlds/ReHLDS/blob/master/rehlds/engine/sv_user.cpp);
a mismatch is the familiar "Bad file" kick.

The important word is *specify*, not *same*:

- `force_model_samebounds` would require the model's box to **equal** the stock one;
- `force_model_specifybounds` requires it to **fit inside** the given envelope.

That is why ordinary humanoid reskins — and even a chicken in a player slot — pass, and only
inflated geometry is kicked.

Two practical notes for anyone implementing the check:

- The box that matters is the geometry in the **reference pose** (sequence 0, frame 0), bones
  applied — not the `bbmin`/`bbmax` fields an exporter happened to write in the header.
- Calibrate on stock first: the stock models obviously pass, so a checker that flags them is
  measuring the wrong thing.

## What this page does not cover

Crashes (as opposed to kicks), server-side plugins that whitelist models by hash, and
`mp_consistency` checks on files other than player models.

## Verified

| Claim | How |
|---|---|
| external + non-÷16 → rejected; each alone → fine | in game, on models of each kind; the refined rule replaced two earlier rules that mis-flagged working models |
| envelope values, *specify* vs *same* | read from ReGameDLL_CS / ReHLDS source, linked above |
| catalogue counts | run over 711 model resources; all 9 stock models pass |

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
