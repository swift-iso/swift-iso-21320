import Byte_Primitives
import Testing

@testable import ISO_21320

@Suite("ISO 21320 Tests")
struct ISO_21320_Tests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `CRC-32 checksum`() {

        let data: [Byte] = "123456789".utf8.map(Byte.init)
        let crc = ISO_21320.CRC.`32`.checksum(data)
        #expect(crc == 0xCBF4_3926)
    }

    @Test
    func `Empty archive`() {
        var archive = ISO_21320.Archive()
        let bytes = archive.finalize()

        #expect(bytes.count >= 22)

        #expect(bytes[0] == 0x50)
        #expect(bytes[1] == 0x4B)
    }

    @Test
    func `Archive with stored file`() {
        var archive = ISO_21320.Archive()
        archive.add(path: "test.txt", content: "Hello", compress: false)
        let bytes = archive.finalize()

        #expect(bytes.count > 22)

        #expect(bytes[0] == 0x50)
        #expect(bytes[1] == 0x4B)
        #expect(bytes[2] == 0x03)
        #expect(bytes[3] == 0x04)
    }

    @Test
    func `Archive with compressed file`() {
        var archive = ISO_21320.Archive()

        let content = String(repeating: "Hello World! ", count: 100)
        archive.add(path: "test.txt", content: content, compress: true)
        let bytes = archive.finalize()

        #expect(bytes.count < content.utf8.count)
    }

    @Test
    func `EPUB mimetype first`() {
        var archive = ISO_21320.Archive()
        archive.add(path: "mimetype", content: "application/epub+zip", compress: false)
        archive.add(path: "META-INF/container.xml", content: "<xml/>", compress: true)
        let bytes = archive.finalize()

        #expect(bytes[8] == 0x00)
        #expect(bytes[9] == 0x00)
    }
}
