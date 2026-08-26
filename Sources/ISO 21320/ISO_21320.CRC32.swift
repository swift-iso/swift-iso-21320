public import Byte
import Standard_Library_Extensions

extension ISO_21320.CRC {

    public enum `32` {}
}

extension ISO_21320.CRC.`32` {

    private static let table: [UInt32] = {
        var table = [UInt32](repeating: 0, count: 256)
        table.indices.forEach { i in
            var crc = UInt32(i)
            for _ in 0..<8 {
                if crc & 1 != 0 {
                    crc = (crc >> 1) ^ 0xEDB8_8320
                } else {
                    crc >>= 1
                }
            }
            table[i] = crc
        }
        return table
    }()

    public static func checksum<Bytes>(_ data: Bytes) -> UInt32
    where Bytes: Swift.Sequence, Bytes.Element == Byte {

        var crc: UInt32 = 0xFFFF_FFFF
        for byte in data {
            let index = Int((crc ^ UInt32(byte.underlying)) & 0xFF)
            crc = (crc >> 8) ^ table[index]
        }
        return crc ^ 0xFFFF_FFFF
    }

}
