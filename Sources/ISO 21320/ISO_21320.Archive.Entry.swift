extension ISO_21320.Archive {

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

            self.modificationTime = 0
            self.modificationDate = 0x0021

            if compress && !uncompressedData.isEmpty {

                let deflated = RFC_1951.compress(
                    uncompressedData.lazy.map(Byte.init),
                    level: .balanced
                )

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

        output.append(contentsOf: [0x50, 0x4B, 0x03, 0x04])

        writeUInt16(compressionMethod == .deflate ? 20 : 10, to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(compressionMethod.rawValue, to: &output)

        writeUInt16(modificationTime, to: &output)

        writeUInt16(modificationDate, to: &output)

        writeUInt32(crc32, to: &output)

        writeUInt32(UInt32(compressedData.count), to: &output)

        writeUInt32(UInt32(uncompressedData.count), to: &output)

        writeUInt16(UInt16(pathBytes.count), to: &output)

        writeUInt16(0, to: &output)

        output.append(contentsOf: pathBytes)
    }

    func writeCentralHeader(localOffset: UInt32, to output: inout [UInt8]) {
        let pathBytes = Array(path.utf8)

        output.append(contentsOf: [0x50, 0x4B, 0x01, 0x02])

        writeUInt16(0x031E, to: &output)

        writeUInt16(compressionMethod == .deflate ? 20 : 10, to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(compressionMethod.rawValue, to: &output)

        writeUInt16(modificationTime, to: &output)

        writeUInt16(modificationDate, to: &output)

        writeUInt32(crc32, to: &output)

        writeUInt32(UInt32(compressedData.count), to: &output)

        writeUInt32(UInt32(uncompressedData.count), to: &output)

        writeUInt16(UInt16(pathBytes.count), to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(0, to: &output)

        writeUInt32(0x81A4_0000, to: &output)

        writeUInt32(localOffset, to: &output)

        output.append(contentsOf: pathBytes)
    }
}
