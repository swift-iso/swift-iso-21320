internal import Byte_Primitives
public import ISO_21320

extension ISO_21320.CRC.`32` {

    @_disfavoredOverload
    public static func checksum<Bytes>(_ data: Bytes) -> UInt32
    where Bytes: Swift.Sequence, Bytes.Element == UInt8 {
        Self.checksum(data.lazy.map(Byte.init))
    }
}
