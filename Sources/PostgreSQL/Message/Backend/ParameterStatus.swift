import Stream

extension BackendMessage {
    struct ParameterStatus {
        let name: String
        let value: String

        static func decode(from stream: SubStreamReader) async throws -> Self {
            let name = try await stream.readCString()
            let value = try await stream.readCString()
            return .init(name: name, value: value)
        }
    }
}
