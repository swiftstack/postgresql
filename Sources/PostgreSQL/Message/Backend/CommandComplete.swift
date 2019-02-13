import Stream

extension BackendMessage {
    struct CommandComplete {
        let tag: String

        init(from stream: SubStreamReader) throws {
            self.tag = try stream.readCString()
        }
    }
}
