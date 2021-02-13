import Stream

extension BackendMessage {
    struct CommandComplete {
        let tag: String

        static func decode(from stream: SubStreamReader) async throws -> Self {
            return .init(tag: try await stream.readCString())
        }
    }
}
