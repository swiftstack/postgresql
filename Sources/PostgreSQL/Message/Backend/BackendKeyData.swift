import Stream

extension BackendMessage {
    struct BackendKeyData {
        let processId: Int
        let secretKey: Int

        init(from stream: SubStreamReader) throws {
            guard stream.limit == 8 else {
                fatalError("BackendKeyData: invalid size")
            }
            self.processId = Int(try stream.read(Int32.self))
            self.secretKey = Int(try stream.read(Int32.self))
        }
    }
}
