extension ISO_21320.File {

    public struct Entry: Sendable {

        public var path: String

        public var data: [UInt8]

        public var compression: ISO_21320.Compression.Method

        public var modificationTime: UInt16

        public var modificationDate: UInt16

        public init(
            path: String,
            data: [UInt8],
            compression: ISO_21320.Compression.Method = .deflate,
            modificationTime: UInt16 = 0,
            modificationDate: UInt16 = 0x0021
        ) {
            self.path = path
            self.data = data
            self.compression = compression
            self.modificationTime = modificationTime
            self.modificationDate = modificationDate
        }
    }
}
