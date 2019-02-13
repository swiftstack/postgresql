import Stream

enum FrontendMessage: StreamEncodable {
    public enum RawType: UInt8 {
        case bind         = 66  // 'B'
        case close        = 67  // 'C'
        case copyData     = 100 // 'c'
        case copyFail     = 102 // 'f'
        case describe     = 68  // 'D'
        case execute      = 69  // 'E'
        case flush        = 72  // 'H'
        case functionCall = 70  // 'F'
        case parse        = 80  // 'P'
        case password     = 112 // 'p'
        case query        = 81  // 'Q'
        case sync         = 83  // 'S'
        case terminate    = 88  // 'X'
    }

    case startup(Startup)
    case query(Query)

    func encode(to stream: StreamWriter) throws {
        switch self {
        case .startup(let message):
            try message.encode(to: stream)
        case .query(let message):
            try stream.write(UInt8(RawType.query.rawValue))
            try stream.withSubStreamWriter(
                sizedBy: Int32.self,
                includingHeader: true,
                task: message.encode)
        }
    }

    struct Startup: StreamEncodable {
        let user: String
        let database: String?
        let replication: Replication?

        enum Replication {
            case `true`
            case `false`
            case database
        }

        init(
            user: String,
            database: String? = nil,
            replication: Replication? = nil)
        {
            self.user = user
            self.database = database
            self.replication = replication
        }

        func encode(to stream: StreamWriter) throws {
            try stream.withSubStreamWriter(
                sizedBy: Int32.self,
                includingHeader: true)
            { stream in
                try stream.write(PostgreSQL.protocolVersion)
                try stream.write(cString: "user")
                try stream.write(cString: user)
                try stream.write(cString: database ?? "")
            }
            try stream.flush()
        }
    }
}

extension FrontendMessage: RawRepresentable {
    var rawValue: UInt8 {
        switch self {
            case .startup: fatalError("startup message doesn't have a type")
            case .query: return RawType.query.rawValue
        }
    }

    init?(rawValue: UInt8) {
        return nil
    }
}
