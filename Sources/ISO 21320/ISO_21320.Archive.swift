internal import Byte
import RFC_1951

extension ISO_21320 {

    public struct Archive: Sendable {

        private var entries: [Entry]

        private var size: (local: Int, central: Int)

        public init() {
            self.entries = []
            self.size = (0, 0)
        }
    }
}

extension ISO_21320.Archive {

    public mutating func add(
        // swift-linter:disable:next raw concept
        // REASON: An archive entry's name inside a ZIP, forward-slash text the format defines, not a path on this file system; looked at Path (File.Path), whose platform code units and refusals don't describe it.
        path: String,
        data: [UInt8],
        compress: Bool = true
    ) throws(ISO_21320.Archive.Error) {
        let length = path.utf8.count
        guard length <= Int(UInt16.max) else { throw .path(length: length) }
        guard entries.count < Int(UInt16.max) - 1 else { throw .entries(count: entries.count + 1) }
        guard data.count < Int(UInt32.max) else { throw .entry(size: data.count) }
        let entry = Entry(
            path: path,
            uncompressedData: data,
            compress: compress
        )
        let stored = entry.compressedData.count
        guard stored < Int(UInt32.max) else { throw .entry(size: stored) }
        let local = size.local + 30 + length + stored
        let central = size.central + 46 + length
        guard local < Int(UInt32.max), central < Int(UInt32.max) else { throw .archive(size: local + central + 22) }
        size = (local, central)
        entries.append(entry)
    }

    public mutating func add(
        // swift-linter:disable:next raw concept
        // REASON: An archive entry's name inside a ZIP, forward-slash text the format defines, not a path on this file system; looked at Path (File.Path), whose platform code units and refusals don't describe it.
        path: String,
        content: String,
        compress: Bool = true
    ) throws(ISO_21320.Archive.Error) {
        try add(path: path, data: Array(content.utf8), compress: compress)
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
