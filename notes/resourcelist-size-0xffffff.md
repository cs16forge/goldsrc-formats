# A file size of `16777215` in the resource list means "unknown"

**Fact.** In the GoldSrc `svc_resourcelist` message the download size of each resource is a
**24-bit field**. Servers that do not know a file's size send −1, which arrives truncated as
`0xFFFFFF` = **16777215**. It is a sentinel, not "16 MB".

**Source.** [ReHLDS `sv_main.cpp`](https://github.com/rehlds/ReHLDS/blob/master/rehlds/engine/sv_main.cpp):
`MSG_WriteBits(r->nDownloadSize, 24)`, next to 4 bits of type, the index, and 3 bits of flags.

**How it shows up.** A server's download list shows a few files of exactly 16777215 bytes each,
and no file is ever larger. On disk those files turn out to be small — in one case four sounds
reported that way weighed 4.6 MB in total.

**What to do.**

- Treat `0xFFFFFF` as "size unknown" (`null`). Do not add it to a "total download size" — a
  handful of such entries inflates the total by gigabytes.
- A file that really is larger than 16 MB would arrive modulo 2^24 and be indistinguishable from
  a small one. That is a protocol limit; nothing to fix on the reading side.
- If you need the true size, ask the server's FastDL host with an HTTP `HEAD` request
  (`Content-Length`; for `.bz2` that is the compressed size).

---
Source: [cs16forge.com](https://cs16forge.com/) · CC BY 4.0
