// MARK: - Internal Entry

extension ISO_21320.Archive {
    /// Internal entry with pre-computed compressed data.
    struct Entry: Sendable {
        let path: String
        let uncompressedData: [UInt8]
        let compressedData: [UInt8]
        let compressionMethod: ISO_21320.Compression.Method
        let crc32: UInt32
        let modificationTime: UInt16
        let modificationDate: UInt16

        init(path: String, uncompressedData: [UInt8], compress: Bool) {
            self.path = path
            self.uncompressedData = uncompressedData
            self.crc32 = ISO_21320.CRC.`32`.checksum(uncompressedData.lazy.map(Byte.init))

            // Use current-ish date: 1980-01-01 00:00:00 (minimum DOS date)
            self.modificationTime = 0
            self.modificationDate = 0x0021

            if compress && !uncompressedData.isEmpty {
                // RFC_1951.compress is byte-typed (Element == Byte) post-cascade; bridge the
                // [UInt8] entry data in/out at this single off-PDF-chain call site.
                let deflated = RFC_1951.compress(
                    uncompressedData.lazy.map(Byte.init),
                    level: .balanced
                )
                // Only use compression if it actually saves space
                if deflated.count < uncompressedData.count {
                    self.compressedData = deflated.map { $0.underlying }
                    self.compressionMethod = .deflate
                } else {
                    self.compressedData = uncompressedData
                    self.compressionMethod = .stored
                }
            } else {
                self.compressedData = uncompressedData
                self.compressionMethod = .stored
            }
        }
    }
}

extension ISO_21320.Archive.Entry {
    func writeLocalHeader(to output: inout [UInt8]) {
        let pathBytes = Array(path.utf8)

        // Local file header signature
        output.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])

        // Version needed to extract (2.0 for deflate)
        writeUInt16(compressionMethod == .deflate ? 20 : 10, to: &output)

        // General purpose bit flag
        writeUInt16(0, to: &output)

        // Compression method
        // swift-linter:disable:next raw value access
        // REASON: same-package implementation — serializing the enum's own wire-format code into the ZIP local/central header.
        writeUInt16(compressionMethod.rawValue, to: &output)

        // Last mod file time
        writeUInt16(modificationTime, to: &output)

        // Last mod file date
        writeUInt16(modificationDate, to: &output)

        // CRC-32
        writeUInt32(crc32, to: &output)

        // Compressed size
        writeUInt32(UInt32(compressedData.count), to: &output)

        // Uncompressed size
        writeUInt32(UInt32(uncompressedData.count), to: &output)

        // File name length
        writeUInt16(UInt16(pathBytes.count), to: &output)

        // Extra field length
        writeUInt16(0, to: &output)

        // File name
        output.append(contentsOf: pathBytes)
    }

    func writeCentralHeader(localOffset: UInt32, to output: inout [UInt8]) {
        let pathBytes = Array(path.utf8)

        // Central file header signature
        output.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])

        // Version made by (Unix, 2.0)
        writeUInt16(0x031E, to: &output)

        // Version needed to extract
        writeUInt16(compressionMethod == .deflate ? 20 : 10, to: &output)

        // General purpose bit flag
        writeUInt16(0, to: &output)

        // Compression method
        // swift-linter:disable:next raw value access
        // REASON: same-package implementation — serializing the enum's own wire-format code into the ZIP local/central header.
        writeUInt16(compressionMethod.rawValue, to: &output)

        // Last mod file time
        writeUInt16(modificationTime, to: &output)

        // Last mod file date
        writeUInt16(modificationDate, to: &output)

        // CRC-32
        writeUInt32(crc32, to: &output)

        // Compressed size
        writeUInt32(UInt32(compressedData.count), to: &output)

        // Uncompressed size
        writeUInt32(UInt32(uncompressedData.count), to: &output)

        // File name length
        writeUInt16(UInt16(pathBytes.count), to: &output)

        // Extra field length
        writeUInt16(0, to: &output)

        // File comment length
        writeUInt16(0, to: &output)

        // Disk number start
        writeUInt16(0, to: &output)

        // Internal file attributes
        writeUInt16(0, to: &output)

        // External file attributes (Unix regular file, 0644)
        writeUInt32(0x81A4_0000, to: &output)

        // Relative offset of local header
        writeUInt32(localOffset, to: &output)

        // File name
        output.append(contentsOf: pathBytes)
    }
}
