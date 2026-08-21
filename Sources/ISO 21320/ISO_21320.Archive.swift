internal import Byte_Primitives
import RFC_1951

extension ISO_21320 {

    public struct Archive: Sendable {

        private var entries: [Entry]

        public init() {
            self.entries = []
        }
    }
}

extension ISO_21320.Archive {

    public mutating func add(
        path: String,
        data: [UInt8],
        compress: Bool = true
    ) {
        let entry = Entry(
            path: path,
            uncompressedData: data,
            compress: compress
        )
        entries.append(entry)
    }

    public mutating func add(
        path: String,
        content: String,
        compress: Bool = true
    ) {
        add(path: path, data: Array(content.utf8), compress: compress)
    }

    public consuming func finalize() -> [UInt8] {
        var output: [UInt8] = []
        var centralDirectory: [UInt8] = []
        var offsets: [UInt32] = []

        for entry in entries {
            offsets.append(UInt32(output.count))
            entry.writeLocalHeader(to: &output)
            output.append(contentsOf: entry.compressedData)
        }

        let centralDirectoryOffset = UInt32(output.count)

        for (index, entry) in entries.enumerated() {
            entry.writeCentralHeader(localOffset: offsets[index], to: &centralDirectory)
        }
        output.append(contentsOf: centralDirectory)

        writeEndOfCentralDirectory(
            entryCount: UInt16(entries.count),
            centralDirectorySize: UInt32(centralDirectory.count),
            centralDirectoryOffset: centralDirectoryOffset,
            to: &output
        )

        return output
    }
}

extension ISO_21320.Archive {
    func writeEndOfCentralDirectory(
        entryCount: UInt16,
        centralDirectorySize: UInt32,
        centralDirectoryOffset: UInt32,
        to output: inout [UInt8]
    ) {

        output.append(contentsOf: [0x50, 0x4B, 0x05, 0x06])

        writeUInt16(0, to: &output)

        writeUInt16(0, to: &output)

        writeUInt16(entryCount, to: &output)

        writeUInt16(entryCount, to: &output)

        writeUInt32(centralDirectorySize, to: &output)

        writeUInt32(centralDirectoryOffset, to: &output)

        writeUInt16(0, to: &output)
    }
}

func writeUInt16(_ value: UInt16, to output: inout [UInt8]) {
    output.append(UInt8(value & 0xFF))
    output.append(UInt8((value >> 8) & 0xFF))
}

func writeUInt32(_ value: UInt32, to output: inout [UInt8]) {
    output.append(UInt8(value & 0xFF))
    output.append(UInt8((value >> 8) & 0xFF))
    output.append(UInt8((value >> 16) & 0xFF))
    output.append(UInt8((value >> 24) & 0xFF))
}
