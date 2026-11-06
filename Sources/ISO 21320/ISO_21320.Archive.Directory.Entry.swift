extension ISO_21320.Archive.Directory {

    /// One entry of an archive's central directory: its path, how it is compressed, and the CRC-32 and size of its
    /// uncompressed bytes.
    public struct Entry: Sendable, Hashable {

        // swift-linter:disable:next raw concept
        // REASON: An archive entry's name inside a ZIP, forward-slash text the format defines, not a path on this file system; looked at Path (File.Path), whose platform code units and refusals don't describe it.
        public let path: String

        public let compression: ISO_21320.Compression.Method

        public let checksum: UInt32

        /// The count of the entry's uncompressed bytes.
        public let size: Int

        /// The entry's stored bytes within the archive.
        let range: Range<Int>

        init(
            path: String,
            compression: ISO_21320.Compression.Method,
            checksum: UInt32,
            size: Int,
            range: Range<Int>
        ) {
            self.path = path
            self.compression = compression
            self.checksum = checksum
            self.size = size
            self.range = range
        }
    }
}
