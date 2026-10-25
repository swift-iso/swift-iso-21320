public import Byte
internal import Binary
import RFC_1951

extension ISO_21320.Archive {

    /// The central directory of an archive: every entry it holds, listed from the archive's bytes without inflating
    /// any of them. ``read(_:)`` inflates one entry through RFC 1951 and checks its size and CRC-32.
    ///
    /// Reads the classic ZIP structures ISO/IEC 21320-1 profiles: stored and deflated entries, no encryption, one
    /// disk. ZIP64 records are refused, as ``ISO_21320/Archive`` refuses to write them.
    public struct Directory: Sendable {

        public let entries: [ISO_21320.Archive.Directory.Entry]

        let bytes: [Byte]

        init(entries: [ISO_21320.Archive.Directory.Entry], bytes: [Byte]) {
            self.entries = entries
            self.bytes = bytes
        }
    }
}

extension ISO_21320.Archive.Directory {

    /// Lists the entries of the archive in `bytes`, in central directory order.
    public init(_ bytes: [Byte]) throws(ISO_21320.Archive.Directory.Error) {
        let end = try Self.end(in: bytes)
        let count: UInt16 = try Self.field(in: bytes, at: end + 10)
        let size: UInt32 = try Self.field(in: bytes, at: end + 12)
        let offset: UInt32 = try Self.field(in: bytes, at: end + 16)
        guard count != .max, size != .max, offset != .max else { throw .zip64 }
        var position = try Self.position(offset)
        let entries = try (0..<Int(count)).map { _ throws(ISO_21320.Archive.Directory.Error) in
            try Self.entry(in: bytes, at: &position)
        }
        self.init(entries: entries, bytes: bytes)
    }

    /// The uncompressed bytes of `entry`, inflated when it is deflated, refused when its size or CRC-32 disagrees
    /// with the directory.
    public func read(
        _ entry: ISO_21320.Archive.Directory.Entry
    ) throws(ISO_21320.Archive.Directory.Error) -> [Byte] {
        guard entry.range.upperBound <= bytes.count else { throw .truncated }
        let stored = bytes[entry.range]
        let data: [Byte]
        switch entry.compression {
        case .stored:
            data = Array(stored)
        case .deflate:
            do throws(RFC_1951.Error) {
                data = try RFC_1951.decompress(stored)
            } catch {
                throw .deflate(error)
            }
        }
        guard data.count == entry.size else { throw .size(expected: entry.size, found: data.count) }
        let checksum = ISO_21320.CRC.`32`.checksum(data)
        guard checksum == entry.checksum else { throw .checksum(expected: entry.checksum, found: checksum) }
        return data
    }
}

extension ISO_21320.Archive.Directory {

    /// The record signatures, little-endian `PK` pairs.
    static let signature = (
        central: UInt32(0x0201_4B50),
        local: UInt32(0x0403_4B50),
        end: UInt32(0x0605_4B50)
    )

    /// The fixed lengths of the end of central directory record, a central directory header and a local file header.
    static let length = (end: 22, central: 46, local: 30)

    /// The position of the end of central directory record: the last signature that leaves room for the record,
    /// searched back over at most a maximal archive comment.
    static func end(in bytes: [Byte]) throws(ISO_21320.Archive.Directory.Error) -> Int {
        guard bytes.count >= length.end else { throw .unterminated }
        let last = bytes.count - length.end
        let first = max(0, last - Int(UInt16.max))
        guard
            let position = stride(from: last, through: first, by: -1).first(where: { position in
                Self.integer(in: bytes, at: position) as UInt32? == Self.signature.end
            })
        else { throw .unterminated }
        return position
    }

    /// The central directory header at `position`, advancing `position` past it, with the range of the entry's
    /// stored bytes found through its local file header.
    static func entry(
        in bytes: [Byte],
        at position: inout Int
    ) throws(ISO_21320.Archive.Directory.Error) -> ISO_21320.Archive.Directory.Entry {
        let header = position
        let signature: UInt32 = try field(in: bytes, at: header)
        guard signature == Self.signature.central else {
            throw .signature(expected: Self.signature.central, found: signature)
        }
        let flags: UInt16 = try field(in: bytes, at: header + 8)
        let method: UInt16 = try field(in: bytes, at: header + 10)
        let checksum: UInt32 = try field(in: bytes, at: header + 16)
        let compressed: UInt32 = try field(in: bytes, at: header + 20)
        let size: UInt32 = try field(in: bytes, at: header + 24)
        let name: UInt16 = try field(in: bytes, at: header + 28)
        let extra: UInt16 = try field(in: bytes, at: header + 30)
        let comment: UInt16 = try field(in: bytes, at: header + 32)
        let offset: UInt32 = try field(in: bytes, at: header + 42)
        let path = try text(in: bytes, at: header + length.central, count: Int(name))
        guard compressed != .max, size != .max, offset != .max else { throw .zip64 }
        guard flags & 1 == 0 else { throw .encrypted(path: path) }
        guard let compression = ISO_21320.Compression.Method(rawValue: method) else {
            throw .compression(path: path, method: method)
        }
        let local = try Self.position(offset)
        let found: UInt32 = try field(in: bytes, at: local)
        guard found == Self.signature.local else { throw .signature(expected: Self.signature.local, found: found) }
        let prefix: (name: UInt16, extra: UInt16) = (
            try field(in: bytes, at: local + 26),
            try field(in: bytes, at: local + 28)
        )
        let start = local + length.local + Int(prefix.name) + Int(prefix.extra)
        let stored = try Self.position(compressed)
        let uncompressed = try Self.position(size)
        guard start <= bytes.count, stored <= bytes.count - start else { throw .truncated }
        position = header + length.central + Int(name) + Int(extra) + Int(comment)
        return ISO_21320.Archive.Directory.Entry(
            path: path,
            compression: compression,
            checksum: checksum,
            size: uncompressed,
            range: start..<start + stored
        )
    }

    /// The little-endian integer at `offset`, or `nil` when it would run past the end of `bytes`.
    static func integer<Integer: FixedWidthInteger>(in bytes: [Byte], at offset: Int) -> Integer? {
        let width = MemoryLayout<Integer>.size
        guard offset >= 0, offset <= bytes.count - width else { return nil }
        return Integer(bytes: bytes[offset..<offset + width])
    }

    static func field<Integer: FixedWidthInteger>(
        in bytes: [Byte],
        at offset: Int
    ) throws(ISO_21320.Archive.Directory.Error) -> Integer {
        guard let value: Integer = integer(in: bytes, at: offset) else { throw .truncated }
        return value
    }

    static func text(
        in bytes: [Byte],
        at offset: Int,
        count: Int
    ) throws(ISO_21320.Archive.Directory.Error) -> String {
        guard offset <= bytes.count, count <= bytes.count - offset else { throw .truncated }
        return String(decoding: bytes[offset..<offset + count].lazy.map(\.underlying), as: UTF8.self)
    }

    static func position(_ value: UInt32) throws(ISO_21320.Archive.Directory.Error) -> Int {
        guard let position = Int(exactly: value) else { throw .truncated }
        return position
    }
}
