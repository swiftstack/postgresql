import Stream
import Network

public enum PostgreSQL {
    static let protocolVersion: Int32 = 196608

    public class Client {
        let client: Network.Client
        var stream: BufferedStream<NetworkStream>! = nil

        var config: [String : String] = [:]
        var keyData: BackendMessage.BackendKeyData? = nil
        var lastTransactionStatus: BackendMessage.TransactionStatus? = nil

        public init(host: String, port: Int) {
            self.client = Network.Client(host: host, port: port)
        }

        public func connect(user: String, database: String? = nil) throws {
            if client.isConnected {
                try? client.disconnect()
            }
            self.stream = try self.client.connect()
            try start(user: user, database: database)
        }

        typealias Startup = FrontendMessage.Startup
        typealias Query = FrontendMessage.Query

        public func query(_ string: String) throws -> DataRowIterator {
            let response = try request(.query(.init(string)))
            return try DataRowIterator(response)
        }

        private func start(user: String, database: String?) throws {
            let response = try request(
                .startup(.init(user: user, database: database)))
            guard let status = response.next() else {
                fatalError("invalid response")
            }
            switch status {
            case .authentication(.ok): readConfiguration(from: response)
            case .error(let error): print(error); response.dump()
            default: fatalError("unknown authentication response")
            }
        }

        private func request(_ message: FrontendMessage) throws
            -> BackendMessageIterator
        {
            guard let stream = stream else {
                fatalError("undefined is not an object")
            }
            try message.encode(to: stream)
            try stream.flush()
            return BackendMessageIterator(stream)
        }

        private func readConfiguration(from response: BackendMessageIterator) {
            config.removeAll()
            while let next = response.next() {
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
    class BackendMessageIterator: IteratorProtocol {
        let stream: StreamReader
        var isDone: Bool = false

        init(_ stream: StreamReader) {
            self.stream = stream
        }

        func next() -> BackendMessage? {
            guard !isDone else { return nil }
            do {
                let message = try BackendMessage(from: stream)
                switch message {
                case .readyForQuery, .error: isDone = true
                default: break
                }
                return message
            } catch {
                fatalError("BackendResponseIterator: \(error)")
            }
        }

        func dump() {
            while let next = next() {
                print(next)
            }
        }
    }

    public class DataRowIterator: IteratorProtocol, Sequence {
        let response: BackendMessageIterator
        let header: RowDescription

        init(_ response: BackendMessageIterator) throws {
            guard case .some(.rowDescription(let header)) = response.next()
            else { fatalError("DataRowIterator: invalid RowDescription") }
            self.response = response
            self.header = header
        }

        public func next() -> DataRow? {
            switch response.next() {
            case .some(.dataRow(let row)):
                return row
            case .some(.commandComplete(_)):
                guard case .some(.readyForQuery) = response.next() else {
                    fatalError("DataRowIterator: invalid end")
                }
                return nil
            default: // .none + other cases
                fatalError("DataRowIterator: invalid DataRow")
            }
        }
    }
}

extension PostgreSQL.DataRowIterator: CustomStringConvertible {
    public var description: String {
        var result = header.columns.map{ $0.name }.joined(separator: " | ")
        for row in self {
            result.append("\n")
            result.append(row.values.joined(separator: " | " ))
        }
        return result
    }
}
