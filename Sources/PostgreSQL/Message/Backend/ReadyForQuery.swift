import Stream

extension BackendMessage {
    enum TransactionStatus: Int8 {
        case idle        = 73 // "I"
        case transaction = 84 // "T"
        case error       = 69 // "E"

        static func decode(from stream: SubStreamReader) async throws -> Self {
            guard stream.limit == 1 else {
                fatalError("TransactionStatus: invalid size")
            }
            let rawStatus = try await stream.read(Int8.self)
            guard let status = TransactionStatus(rawValue: rawStatus) else {
                fatalError("TransactionStatus: invalid status")
            }
            return status
        }
    }
}

extension BackendMessage.TransactionStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .idle: return "idle (not in a transaction block)"
        case .transaction: return "in a transaction block"
        case .error: return "in a failed transaction block " +
                            "(queries will be rejected until block is ended)"
        }
    }
}
