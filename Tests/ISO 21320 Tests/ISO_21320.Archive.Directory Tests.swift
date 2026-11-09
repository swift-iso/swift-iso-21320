import Byte
import Testing

@testable import ISO_21320

enum `ISO_21320.Archive.Directory Tests` {}

extension `ISO_21320.Archive.Directory Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `ISO_21320.Archive.Directory Tests`.Test {
    static func written(
        _ build: (inout ISO_21320.Archive) throws(ISO_21320.Archive.Error) -> Void
    ) throws(ISO_21320.Archive.Error) -> [Byte] {
        var archive = ISO_21320.Archive()
        try build(&archive)
        return archive.finalize().map(Byte.init(bitPattern:))
    }

    static func bytes(_ text: String) -> [Byte] {
        text.utf8.map(Byte.init(bitPattern:))
    }

    /// `ditto -c -k --norsrc --noextattr` over `a.txt` ("x"), `word/` and `word/document.xml` (48 bytes): deflated
    /// entries with data descriptors (local sizes and checksums zero) and local extra fields longer than the central ones.
    static let ditto: [Byte] = [
        0x50, 0x4b, 0x03, 0x04, 0x14, 0x00, 0x08, 0x00, 0x08, 0x00, 0x25, 0x6e, 0x59, 0x5d, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x10, 0x00, 0x61, 0x2e,
        0x74, 0x78, 0x74, 0x55, 0x58, 0x0c, 0x00, 0xc6, 0xfa, 0xdd, 0x6a, 0xc6, 0xfa, 0xdd, 0x6a, 0xf5,
        0x01, 0x00, 0x00, 0xab, 0x00, 0x00, 0x50, 0x4b, 0x07, 0x08, 0x83, 0x16, 0xdc, 0x8c, 0x03, 0x00,
        0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x50, 0x4b, 0x03, 0x04, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x25, 0x6e, 0x59, 0x5d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x05, 0x00, 0x10, 0x00, 0x77, 0x6f, 0x72, 0x64, 0x2f, 0x55, 0x58, 0x0c, 0x00, 0xc6, 0xfa, 0xdd,
        0x6a, 0xc6, 0xfa, 0xdd, 0x6a, 0xf5, 0x01, 0x00, 0x00, 0x50, 0x4b, 0x03, 0x04, 0x14, 0x00, 0x08,
        0x00, 0x08, 0x00, 0x25, 0x6e, 0x59, 0x5d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x11, 0x00, 0x10, 0x00, 0x77, 0x6f, 0x72, 0x64, 0x2f, 0x64, 0x6f, 0x63, 0x75,
        0x6d, 0x65, 0x6e, 0x74, 0x2e, 0x78, 0x6d, 0x6c, 0x55, 0x58, 0x0c, 0x00, 0xc6, 0xfa, 0xdd, 0x6a,
        0xc6, 0xfa, 0xdd, 0x6a, 0xf5, 0x01, 0x00, 0x00, 0xf3, 0x48, 0xcd, 0xc9, 0xc9, 0xd7, 0x51, 0x48,
        0x2c, 0x4a, 0xce, 0xc8, 0x2c, 0x4b, 0xd5, 0x53, 0xf0, 0xc0, 0xcf, 0xe7, 0x02, 0x00, 0x50, 0x4b,
        0x07, 0x08, 0xbf, 0x8a, 0x92, 0x0c, 0x16, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x50, 0x4b,
        0x01, 0x02, 0x15, 0x03, 0x14, 0x00, 0x08, 0x00, 0x08, 0x00, 0x25, 0x6e, 0x59, 0x5d, 0x83, 0x16,
        0xdc, 0x8c, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x05, 0x00, 0x0c, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0xa4, 0x81, 0x00, 0x00, 0x00, 0x00, 0x61, 0x2e, 0x74, 0x78,
        0x74, 0x55, 0x58, 0x08, 0x00, 0xc6, 0xfa, 0xdd, 0x6a, 0xc6, 0xfa, 0xdd, 0x6a, 0x50, 0x4b, 0x01,
        0x02, 0x15, 0x03, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x6e, 0x59, 0x5d, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x40, 0xed, 0x41, 0x46, 0x00, 0x00, 0x00, 0x77, 0x6f, 0x72, 0x64, 0x2f,
        0x55, 0x58, 0x08, 0x00, 0xc6, 0xfa, 0xdd, 0x6a, 0xc6, 0xfa, 0xdd, 0x6a, 0x50, 0x4b, 0x01, 0x02,
        0x15, 0x03, 0x14, 0x00, 0x08, 0x00, 0x08, 0x00, 0x25, 0x6e, 0x59, 0x5d, 0xbf, 0x8a, 0x92, 0x0c,
        0x16, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x11, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x40, 0xa4, 0x81, 0x79, 0x00, 0x00, 0x00, 0x77, 0x6f, 0x72, 0x64, 0x2f, 0x64,
        0x6f, 0x63, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x2e, 0x78, 0x6d, 0x6c, 0x55, 0x58, 0x08, 0x00, 0xc6,
        0xfa, 0xdd, 0x6a, 0xc6, 0xfa, 0xdd, 0x6a, 0x50, 0x4b, 0x05, 0x06, 0x00, 0x00, 0x00, 0x00, 0x03,
        0x00, 0x03, 0x00, 0xc9, 0x00, 0x00, 0x00, 0xde, 0x00, 0x00, 0x00, 0x00, 0x00,
    ].map(Byte.init(bitPattern:))
}

extension `ISO_21320.Archive.Directory Tests`.Test.Unit {
    @Test func `the entries list every path written, in order, with its compression and size`() throws {
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "mimetype", content: "application/epub+zip", compress: false)
            try archive.add(path: "word/document.xml", content: String(repeating: "<w:t>Hello</w:t>", count: 50))
        }
        let directory = try ISO_21320.Archive.Directory(bytes)
        #expect(directory.entries.map(\.path) == ["mimetype", "word/document.xml"])
        #expect(directory.entries.map(\.compression) == [.stored, .deflate])
        #expect(directory.entries.map(\.size) == [20, 800])
    }

    @Test func `a stored entry reads back its bytes`() throws {
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "a.txt", content: "Hello", compress: false)
        }
        let directory = try ISO_21320.Archive.Directory(bytes)
        let entry = try #require(directory.entries.first)
        #expect(try directory.read(entry) == `ISO_21320.Archive.Directory Tests`.Test.bytes("Hello"))
    }

    @Test func `a deflated entry inflates back to its bytes`() throws {
        let content = String(repeating: "Hello World! ", count: 100)
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "a.txt", content: "first", compress: false)
            try archive.add(path: "b.txt", content: content)
        }
        let directory = try ISO_21320.Archive.Directory(bytes)
        let entry = try #require(directory.entries.last)
        #expect(entry.compression == .deflate)
        #expect(try directory.read(entry) == `ISO_21320.Archive.Directory Tests`.Test.bytes(content))
    }
}

extension `ISO_21320.Archive.Directory Tests`.Test.`Edge Case` {
    @Test func `an empty archive lists no entries`() throws {
        let directory = try ISO_21320.Archive.Directory(try `ISO_21320.Archive.Directory Tests`.Test.written { _ in })
        #expect(directory.entries.isEmpty)
    }

    @Test func `an empty entry reads back empty`() throws {
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "empty", data: [])
        }
        let directory = try ISO_21320.Archive.Directory(bytes)
        let entry = try #require(directory.entries.first)
        #expect(try directory.read(entry) == [])
    }

    @Test func `bytes that are no archive are refused`() {
        #expect(throws: ISO_21320.Archive.Directory.Error.unterminated) {
            try ISO_21320.Archive.Directory(`ISO_21320.Archive.Directory Tests`.Test.bytes("PK, but not a ZIP archive at all"))
        }
        #expect(throws: ISO_21320.Archive.Directory.Error.unterminated) {
            try ISO_21320.Archive.Directory([])
        }
    }

    @Test func `an archive cut short is refused`() throws {
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "a.txt", content: "Hello", compress: false)
        }
        #expect(throws: ISO_21320.Archive.Directory.Error.self) {
            try ISO_21320.Archive.Directory(Array(bytes.dropFirst(4)))
        }
    }

    @Test func `a trailing archive comment does not hide the directory`() throws {
        var bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "a.txt", content: "Hello", compress: false)
        }
        let comment = `ISO_21320.Archive.Directory Tests`.Test.bytes("a comment")
        bytes[bytes.count - 2] = Byte(bitPattern: UInt8(comment.count))
        bytes.append(contentsOf: comment)
        let directory = try ISO_21320.Archive.Directory(bytes)
        #expect(directory.entries.map(\.path) == ["a.txt"])
    }

    @Test func `a non-ASCII path sets the UTF-8 flag in both headers`() throws {
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "café.txt", data: [], compress: false)
            try archive.add(path: "plain.txt", data: [], compress: false)
        }
        let name = (first: "café.txt".utf8.count, second: "plain.txt".utf8.count)
        let central = try ISO_21320.Archive.Directory.end(in: bytes) - 2 * 46 - name.first - name.second
        let flags: [UInt16?] = [
            ISO_21320.Archive.Directory.integer(in: bytes, at: 6),
            ISO_21320.Archive.Directory.integer(in: bytes, at: 30 + name.first + 6),
            ISO_21320.Archive.Directory.integer(in: bytes, at: central + 8),
            ISO_21320.Archive.Directory.integer(in: bytes, at: central + 46 + name.first + 8),
        ]
        #expect(flags == [0x0800, 0, 0x0800, 0])
        let directory = try ISO_21320.Archive.Directory(bytes)
        #expect(directory.entries.map(\.path) == ["café.txt", "plain.txt"])
    }

    @Test func `an entry name that is not UTF-8 is refused`() throws {
        var bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "é", data: [], compress: false)
        }
        for index in bytes.indices where bytes[index].underlying == 0xC3 {
            bytes[index] = Byte(bitPattern: 0xFF)
        }
        #expect(throws: ISO_21320.Archive.Directory.Error.name([0xFF, 0xA9].map(Byte.init(bitPattern:)))) {
            try ISO_21320.Archive.Directory(bytes)
        }
    }

    @Test func `a corrupted entry fails its checksum`() throws {
        var bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            try archive.add(path: "a.txt", content: "Hello", compress: false)
        }
        let index = try #require(bytes.firstIndex(of: Byte(bitPattern: UInt8(ascii: "H"))))
        bytes[index] = Byte(bitPattern: UInt8(ascii: "J"))
        let directory = try ISO_21320.Archive.Directory(bytes)
        let entry = try #require(directory.entries.first)
        #expect(throws: ISO_21320.Archive.Directory.Error.self) {
            try directory.read(entry)
        }
    }
}

extension `ISO_21320.Archive.Directory Tests`.Test.Integration {
    @Test func `an archive written by ditto, with data descriptors, is listed and read`() throws {
        let directory = try ISO_21320.Archive.Directory(`ISO_21320.Archive.Directory Tests`.Test.ditto)
        #expect(directory.entries.map(\.path) == ["a.txt", "word/", "word/document.xml"])
        #expect(directory.entries.map(\.size) == [1, 0, 48])
        let reads = try directory.entries.map { entry throws(ISO_21320.Archive.Directory.Error) in try directory.read(entry) }
        #expect(
            reads == [
                `ISO_21320.Archive.Directory Tests`.Test.bytes("x"),
                [],
                `ISO_21320.Archive.Directory Tests`.Test.bytes("Hello, archive. Hello, archive. Hello, archive.\n"),
            ]
        )
    }

    @Test func `every entry written reads back unchanged`() throws {
        let contents: [(path: String, content: String, compress: Bool)] = [
            ("mimetype", "application/vnd.openxmlformats", false),
            ("[Content_Types].xml", String(repeating: "<Types/>", count: 40), true),
            ("xl/sharedStrings.xml", "<sst><si><t>Huur</t></si></sst>", true),
            ("xl/worksheets/sheet1.xml", String(repeating: "<c r=\"A1\" t=\"s\"><v>0</v></c>", count: 30), true),
        ]
        let bytes = try `ISO_21320.Archive.Directory Tests`.Test.written { archive throws(ISO_21320.Archive.Error) in
            for item in contents { try archive.add(path: item.path, content: item.content, compress: item.compress) }
        }
        let directory = try ISO_21320.Archive.Directory(bytes)
        let reads = try directory.entries.map { entry throws(ISO_21320.Archive.Directory.Error) in try directory.read(entry) }
        #expect(directory.entries.map(\.path) == contents.map(\.path))
        #expect(reads == contents.map { `ISO_21320.Archive.Directory Tests`.Test.bytes($0.content) })
    }
}
