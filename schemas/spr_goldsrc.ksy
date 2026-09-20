meta:
  id: spr_goldsrc
  title: GoldSrc sprite (IDSP version 2) - Half-Life, Counter-Strike 1.6
  file-extension: spr
  license: MIT
  endian: le
doc: |
  Version 2 differs from Quake's version 1 by the texFormat field and the embedded palette.
doc-ref: https://github.com/cs16forge/goldsrc-formats/blob/main/hud-sprites.md
seq:
  - id: magic
    contents: IDSP
  - id: version
    type: s4
    valid: 2
  - id: orientation
    type: s4
    enum: orientation
  - id: tex_format
    type: s4
    enum: tex_format
  - id: bounding_radius
    type: f4
  - id: max_width
    type: s4
  - id: max_height
    type: s4
  - id: num_frames
    type: s4
  - id: beam_length
    type: f4
  - id: sync_type
    type: s4
  - id: palette_count
    type: s2
  - id: palette
    size: palette_count * 3
  - id: frames
    type: frame_entry
    repeat: expr
    repeat-expr: num_frames
types:
  frame_entry:
    seq:
      - id: frame_type
        type: s4
        doc: 0 = single frame, anything else = group.
      - id: single
        type: frame
        if: frame_type == 0
      - id: group
        type: frame_group
        if: frame_type != 0
  frame_group:
    seq:
      - id: count
        type: s4
      - id: intervals
        type: f4
        repeat: expr
        repeat-expr: count
      - id: frames
        type: frame
        repeat: expr
        repeat-expr: count
  frame:
    seq:
      - id: origin_x
        type: s4
      - id: origin_y
        type: s4
      - id: width
        type: s4
      - id: height
        type: s4
      - id: pixels
        size: width * height
enums:
  orientation:
    0: vp_parallel_upright
    1: facing_upright
    2: vp_parallel
    3: oriented
    4: vp_parallel_oriented
  tex_format:
    0: normal
    1: additive
    2: index_alpha
    3: alpha_test
