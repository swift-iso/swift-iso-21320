import ISO_21320
import ISO_21320_Standard_Library_Integration
import Testing

@Suite("ISO 21320 CRC-32 UInt8 forwarder")
struct ISO_21320_CRC32_UInt8_Tests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `forwarder agrees with primary byte-domain on standard vector`() {
        let uint8Data: [UInt8] = Array("123456789".utf8)
        let crc = ISO_21320.CRC.`32`.checksum(uint8Data)
        #expect(crc == 0xCBF4_3926)
    }
}
