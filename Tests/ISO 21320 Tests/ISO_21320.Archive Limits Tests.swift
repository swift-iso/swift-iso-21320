import Testing

@testable import ISO_21320

@Suite
struct `Archive limits` {
    @Test
    func `a path over 65,535 bytes is refused when it is added`() async {
        await #expect(processExitsWith: .failure) {
            var archive = ISO_21320.Archive()
            archive.add(path: String(repeating: "a", count: 65_536), data: [], compress: false)
        }
    }

    @Test
    func `a path of exactly 65,535 bytes is written`() {
        var archive = ISO_21320.Archive()
        archive.add(path: String(repeating: "a", count: 65_535), data: [], compress: false)
        #expect(archive.finalize().count > 65_535)
    }
}
