import Stream
import Network

public enum PostgreSQL {
    static let protocolVersion: Int32 = 196608

    public class Client {
        let client: TCP.Client
        var stream: BufferedStream<TCP.Stream>! = nil

        var config: [String : String] = [:]
        var keyData: BackendMessage.BackendKeyData? = nil
        var lastTransactionStatus: BackendMessage.TransactionStatus? = nil

        public init(host: String, port: Int) {
            self.client = TCP.Client(host: host, port: port)
        }

        public func connect(
            user: String,
            database: String? = nil
        ) async throws {
            if client.isConnected {
                try? client.disconnect()
            }
            let networkStream = try await self.client.connect()
            self.stream = BufferedStream(baseStream: networkStream)
            try await start(user: user, database: database)
        }

        typealias Startup = FrontendMessage.Startup
        typealias Query = FrontendMessage.Query

        public func query(_ string: String) async throws -> DataRowIterator {
            let response = try await request(.query(.init(string)))
            return try await DataRowIterator.asyncInit(response)
        }

        private func start(user: String, database: String?) async throws {
            let response = try await request(
                .startup(.init(user: user, database: database)))
            guard let status = await response.next() else {
                fatalError("invalid response")
            }
            switch status {
            case .authentication(.ok): await readConfiguration(from: response)
            case .error(let error): print(error); await response.dump()
            default: fatalError("unknown authentication response")
            }
        }

        private func request(_ message: FrontendMessage) async throws
            -> BackendMessageIterator
        {
            guard let stream = stream else {
                fatalError("undefined is not an object")
            }
            try await message.encode(to: stream)
            try await stream.flush()
            return BackendMessageIterator(stream)
        }

        private func readConfiguration(
            from response: BackendMessageIterator
        ) async {
            config.removeAll()
            while let next = await response.next() {
                switch next {
                case .readyForQuery(let transactionStatus):
                    self.lastTransactionStatus = transactionStatus
                    return
                case .parameterStatus(let status):
                    self.config[status.name] = status.value
                case .backendKeyData(let keyData):
                    self.keyData = keyData
                case .error(let error):
                    print(error)
                default: fatalError("invalid message: \(next)")
                }
            }
        }
    }
}

extension PostgreSQL {
    class BackendMessageIterator: AsyncIteratorProtocol {
        let stream: StreamReader
        var isDone: Bool = false

        init(_ stream: StreamReader) {
            self.stream = stream
        }

        func next() async -> BackendMessage? {
            guard !isDone else { return nil }
            do {
                let message = try await BackendMessage.decode(from: stream)
                switch message {
                case .readyForQuery, .error: isDone = true
                default: break
                }
                return message
            } catch {
                fatalError("BackendResponseIterator: \(error)")
            }
        }

        func dump() async {
            while let next = await next() {
                print(next)
            }
        }
    }

    public class DataRowIterator: AsyncIteratorProtocol, AsyncSequence {
        let response: BackendMessageIterator
        let header: RowDescription

        private init(response: BackendMessageIterator, header: RowDescription) {
            self.response = response
            self.header = header
        }

        static func asyncInit(
            _ response: BackendMessageIterator
        ) async throws -> DataRowIterator {
            guard case .some(.rowDescription(let header)) = await response.next()
            else { fatalError("DataRowIterator: invalid RowDescription") }
            return .init(response: response, header: header)
        }

        public func next() async -> DataRow? {
            switch await response.next() {
            case .some(.dataRow(let row)):
                return row
            case .some(.commandComplete(_)):
                guard case .some(.readyForQuery) = await response.next() else {
                    fatalError("DataRowIterator: invalid end")
                }
                return nil
            default: // .none + other cases
                fatalError("DataRowIterator: invalid DataRow")
            }
        }

        public func makeAsyncIterator() -> DataRowIterator {
            return self
        }
    }
}

extension PostgreSQL.DataRowIterator {
    public var description: String {
        get async {
            var result = header.columns.map{ $0.name }.joined(separator: " | ")
            for await row in self {
                result.append("\n")
                result.append(row.values.joined(separator: " | " ))
            }
            return result
        }
    }
}
