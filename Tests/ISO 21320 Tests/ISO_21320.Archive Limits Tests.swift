import Byte
import Testing

@testable import ISO_21320

enum `ISO_21320.Archive Limits Tests` {}

extension `ISO_21320.Archive Limits Tests` {
    @Suite
    struct `Archive limits` {
        @Test
        func `a path over 65,535 bytes is refused when it is added`() {
            var archive = ISO_21320.Archive()
            #expect(throws: ISO_21320.Archive.Error.path(length: 65_536)) {
                try archive.add(path: String(repeating: "a", count: 65_536), data: [], compress: false)
            }
        }

        @Test
        func `a path of exactly 65,535 bytes is written`() throws {
            var archive = ISO_21320.Archive()
            try archive.add(path: String(repeating: "a", count: 65_535), data: [], compress: false)
            #expect(archive.finalize().count > 65_535)
        }

        @Test
        func `an entry past the last one the directory can count is refused`() throws {
            var archive = ISO_21320.Archive()
            for index in 0..<65_534 {
                try archive.add(path: "\(index)", data: [], compress: false)
            }
            #expect(throws: ISO_21320.Archive.Error.entries(count: 65_535)) {
                try archive.add(path: "last", data: [], compress: false)
            }
            let directory = try ISO_21320.Archive.Directory(archive.finalize().map(Byte.init(bitPattern:)))
            #expect(directory.entries.count == 65_534)
        }
    }
}
