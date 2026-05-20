// ISO_21320.CRC32+UInt8.swift
//
// Stdlib-interop UInt8 forwarder for CRC-32 checksum. Primary byte-domain
// API lives in `ISO 21320`; this forwarder bridges stdlib callers carrying
// `Sequence<UInt8>` (e.g. `[UInt8]` from network buffers, file-read frames)
// via `.lazy.map(Byte.init)`. Per [API-BYTE-007] (byte-discipline skill).

public import ISO_21320
internal import Byte_Primitives

extension ISO_21320.CRC.`32` {
    /// Stdlib-interop forwarder: `Bytes.Element == UInt8`.
    @_disfavoredOverload
    public static func checksum<Bytes>(_ data: Bytes) -> UInt32
    where Bytes: Sequence, Bytes.Element == UInt8 {
        Self.checksum(data.lazy.map(Byte.init))
    }
}
