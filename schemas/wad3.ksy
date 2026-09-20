meta:
  id: wad3
  title: GoldSrc texture archive (WAD3) - Half-Life, Counter-Strike 1.6
  file-extension: wad
  license: MIT
  endian: le
doc: |
  WAD3 as used by GoldSrc for map textures, decals and the player spray (tempdecal.wad:
  a single miptex lump named "{LOGO"). Only uncompressed lumps occur in practice.
doc-ref: https://github.com/cs16forge/goldsrc-formats/blob/main/spray-tempdecal.md
seq:
  - id: magic
    contents: WAD3
  - id: num_lumps
    type: u4
  - id: dir_offset
    type: u4
instances:
  directory:
    pos: dir_offset
    type: dir_entry
    repeat: expr
    repeat-expr: num_lumps
types:
  dir_entry:
    seq:
      - id: file_pos
        type: u4
      - id: disk_size
        type: u4
      - id: size
        type: u4
      - id: type
        type: u1
        enum: lump_type
      - id: compression
        type: u1
      - id: padding
        type: u2
      - id: name
        type: strz
        size: 16
        encoding: ASCII
    instances:
      miptex:
        pos: file_pos
        size: disk_size
        type: miptex
        if: type == lump_type::miptex
  miptex:
    seq:
      - id: name
        type: strz
        size: 16
        encoding: ASCII
      - id: width
        type: u4
      - id: height
        type: u4
      - id: mip_offsets
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: From the start of this lump. Level i holds (width >> i) * (height >> i) palette indices.
    instances:
      mip0:
        pos: mip_offsets[0]
        size: width * height
      palette_count:
        pos: mip_offsets[3] + (width >> 3) * (height >> 3)
        type: u2
      palette:
        pos: mip_offsets[3] + (width >> 3) * (height >> 3) + 2
        size: palette_count * 3
        doc: RGB triples. For names starting with "{", index 255 is transparent.
enums:
  lump_type:
    0x40: palette
    0x42: qpic
    0x43: miptex
    0x46: font
