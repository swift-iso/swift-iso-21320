// ISO_21320.CRC32.swift
//
// CRC-32 checksum as used in ZIP files (IEEE 802.3 polynomial).

public import Byte_Primitives
public import Standard_Library_Extensions

extension ISO_21320 {
    /// CRC-32 checksum types.
    public enum CRC {}
}

extension ISO_21320.CRC {
    /// CRC-32 checksum calculator.
    ///
    /// Uses the polynomial 0xEDB88320 (IEEE 802.3, same as used in ZIP, gzip, PNG).
    public enum `32` {
        /// Precomputed CRC-32 lookup table.
        private static let table: [UInt32] = {
            var table = [UInt32](repeating: 0, count: 256)
            for i in 0..<256 {
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

        /// Calculate CRC-32 checksum of data.
        ///
        /// - Parameter data: The bytes to checksum.
        /// - Returns: The CRC-32 checksum.
        public static func checksum<Bytes>(_ data: Bytes) -> UInt32
        where Bytes: Sequence, Bytes.Element == Byte {
            // UInt32 accumulator is arithmetic-domain; cross the byte-domain
            // boundary via .underlying.
            var crc: UInt32 = 0xFFFF_FFFF
            for byte in data {
                let index = Int((crc ^ UInt32(byte.underlying)) & 0xFF)
                crc = (crc >> 8) ^ table[index]
            }
            return crc ^ 0xFFFF_FFFF
        }

        // Stdlib-interop UInt8 forwarder lives in `ISO 21320 Standard Library
        // Integration` per [API-BYTE-007].
    }
}
