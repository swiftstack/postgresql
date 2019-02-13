import Stream

enum BackendMessage {
    enum RawType: UInt8 {
        case authentication           = 82  // 'R'
        case backendKeyData           = 75  // 'K'
        case bindComplete             = 50  // '2'
        case closeComplete            = 51  // '3'
        case commandComplete          = 67  // 'C'
        case copyData                 = 100 // 'c'
        case copyInResponse           = 71  // 'G'
        case copyOutResponse          = 72  // 'H'
        case copyBothResponse         = 87  // 'W'
        case dataRow                  = 68  // 'D'
        case emptyQueryResponse       = 73  // 'I'
        case errorResponse            = 69  // 'E'
        case functionCallResponse     = 86  // 'V'
        case negotiateProtocolVersion = 118 // 'v'
        case noData                   = 110 // 'n'
        case noticeResponse           = 78  // 'N'
        case notificationResponse     = 65  // 'A'
        case parameterDescription     = 116 // 't'
        case parameterStatus          = 83  // 'S'
        case parseComplete            = 49  // '1'
        case postalSuspended          = 115 // 's'
        case readyForQuery            = 90  // 'Z'
        case rowDescription           = 84  // 'T'
    }

    case authentication(Authentication)
    case parameterStatus(ParameterStatus)
    case backendKeyData(BackendKeyData)
    case readyForQuery(TransactionStatus)
    case rowDescription(RowDescription)
    case dataRow(DataRow)
    case commandComplete(CommandComplete)
    case error(Error)

    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let messageType = RawType(rawValue: rawType) else {
            fatalError("unknown message type: \(rawType)")
        }
        self = try stream.withSubStreamReader(
                sizedBy: Int32.self,
                includingHeader: true)
        { stream in
            switch messageType {
            case .authentication:
                return .authentication(try .init(from: stream))
            case .parameterStatus:
                return .parameterStatus(try .init(from: stream))
            case .backendKeyData:
                return .backendKeyData(try .init(from: stream))
            case .readyForQuery:
                return .readyForQuery(try .init(from: stream))
            case .rowDescription:
                return .rowDescription(try .init(from: stream))
            case .dataRow:
                return .dataRow(try .init(from: stream))
            case .commandComplete:
                return .commandComplete(try .init(from: stream))
            case .errorResponse:
                return .error(try .init(from: stream))
            default:
                print("type: \(rawType) size: \(stream.limit)")
                print(try stream.readUntilEnd())
                fatalError()
            }
        }
    }
}
