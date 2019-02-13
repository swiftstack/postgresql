import Stream

extension BackendMessage {
    struct ParameterStatus {
        let name: String
        let value: String

        init(from stream: SubStreamReader) throws {
            self.name = try stream.readCString()
            self.value = try stream.readCString()
        }
    }
}
