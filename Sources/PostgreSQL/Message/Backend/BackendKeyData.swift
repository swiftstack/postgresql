import Stream

extension BackendMessage {
    struct BackendKeyData {
        let processId: Int
        let secretKey: Int

        static func decode(from stream: SubStreamReader) async throws -> Self {
            guard stream.limit == 8 else {
                fatalError("BackendKeyData: invalid size")
            }
            let processId = Int(try await stream.read(Int32.self))
            let secretKey = Int(try await stream.read(Int32.self))
            return .init(processId: processId, secretKey: secretKey)
        }
    }
}
