# swift-iso-21320

Use this package when you need to write or read ZIP archives of the kind ISO/IEC 21320-1 describes, such as the containers of EPUB, OOXML and ODF documents. Write one with `ISO_21320.Archive` and read one with `ISO_21320.Archive.Directory`. If you only need raw deflate compression, use swift-rfc-1951. For a CRC-32 over `UInt8` rather than `Byte`, add the `ISO 21320 Standard Library Integration` product.

## Laws

- Entries are written in the order they are added, so a `mimetype` entry added first stays first.
- With compression on, an entry is deflated only when that makes it smaller. Otherwise, and for every empty entry, it is stored.
- Output is deterministic. Every entry gets the same timestamp, 1 January 1980 at 00:00, and is marked as a Unix file with permissions 0644.
- Paths are written as their UTF-8 bytes, with general purpose flag bit 11 set when a path is not ASCII. `ISO_21320.Archive.add(path:content:compress:)` stores the text's UTF-8 bytes.
- ZIP64 is never written. `ISO_21320.Archive.add` throws `ISO_21320.Archive.Error` for a path over 65,535 bytes, an entry or archive of 4 GiB or more, or a 65,535th entry, and leaves the archive unchanged, so `finalize()` always produces an archive that `ISO_21320.Archive.Directory` reads.
- `ISO_21320.Archive.Directory` lists the entries in central directory order without inflating any of them. It takes sizes and checksums from the central directory, so archives that use data descriptors read correctly.
- The end of central directory record is found by searching back from the end over at most a maximal archive comment, so a trailing comment does not hide the directory.
- Listing fails as a whole if any entry is encrypted, uses a method other than stored or deflate, or needs ZIP64.
- Entry paths are decoded as UTF-8. A name that is not valid UTF-8 fails the listing with its raw bytes.
- `ISO_21320.Archive.Directory.read(_:)` inflates a deflated entry and then checks its size and CRC-32 against the directory. Either mismatch fails the read.
- `ISO_21320.CRC.32` is the standard CRC-32 used by ZIP, gzip and PNG. The checksum of the ASCII text `123456789` is `0xCBF4_3926`.
