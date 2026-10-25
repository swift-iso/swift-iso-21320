public import RFC_1951

extension ISO_21320.Archive.Directory {

    public enum Error: Swift::Error, Sendable, Equatable {

        /// No end of central directory record: the bytes are no archive.
        case unterminated

        /// A record runs past the end of the bytes.
        case truncated

        /// A record does not start with its signature.
        case signature(expected: UInt32, found: UInt32)

        /// The archive uses ZIP64 records.
        case zip64

        /// The entry is encrypted.
        case encrypted(path: String)

        /// The entry uses a compression method other than stored or deflate.
        case compression(path: String, method: UInt16)

        /// The entry's deflated bytes do not inflate.
        case deflate(RFC_1951.Error)

        /// The entry's bytes do not have the size the directory records.
        case size(expected: Int, found: Int)

        /// The entry's bytes do not have the CRC-32 the directory records.
        case checksum(expected: UInt32, found: UInt32)
    }
}
