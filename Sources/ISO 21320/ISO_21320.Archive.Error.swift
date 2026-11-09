extension ISO_21320.Archive {

    public enum Error: Swift::Error, Sendable, Equatable {

        case path(length: Int)

        case entry(size: Int)

        case entries(count: Int)

        case archive(size: Int)
    }
}
