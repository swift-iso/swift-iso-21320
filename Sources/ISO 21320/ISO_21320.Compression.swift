extension ISO_21320.Compression {

    public enum Method: UInt16, Sendable, Hashable {

        case stored = 0

        case deflate = 8
    }
}
