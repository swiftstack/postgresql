import Stream

extension BackendMessage {
    struct Error {
        let fields: [Field]

        struct Field {
            let type: FieldType
            let value: String

            init(from stream: SubStreamReader) throws {
                let rawFieldType = Int(try stream.read(UInt8.self))
                self.type = Field.FieldType(rawValue: rawFieldType)
                self.value = try stream.readCString()
            }

            enum FieldType {
                case severity
                case severityEN
                case code
                case message
                case detail
                case hint
                case position
                case internalPosition
                case internalQuery
                case `where`
                case schemaName
                case tableName
                case columnName
                case dataTypeName
                case constraintName
                case file
                case line
                case routine
                case unknown(Int)
            }
        }

        init(from stream: SubStreamReader) throws {
            var fields = [Field]()
            while !stream.isEmpty {
                // end of error message
                guard try stream.peek() != 0 else {
                    try stream.consume(count: 1)
                    break
                }
                fields.append(try .init(from: stream))
            }
            self.fields = fields
        }
    }
}

extension BackendMessage.Error.Field.FieldType: RawRepresentable {
    enum RawType: Int {
        case severity         = 83  // 'S'
        case severityEN       = 86  // 'V'
        case code             = 67  // 'C'
        case message          = 77  // 'M'
        case detail           = 68  // 'D'
        case hint             = 72  // 'H'
        case position         = 80  // 'P'
        case internalPosition = 112 // 'p'
        case internalQuery    = 113 // 'q'
        case `where`          = 87  // 'W'
        case schemaName       = 115 // 's'
        case tableName        = 116 // 't'
        case columnName       = 99  // 'c'
        case dataTypeName     = 100 // 'd'
        case constraintName   = 110 // 'n'
        case file             = 70  // 'F'
        case line             = 76  // 'L'
        case routine          = 82  // 'R'
    }

    var rawValue: Int {
        switch self {
        case .severity: return RawType.severity.rawValue
        case .severityEN: return RawType.severityEN.rawValue
        case .code: return RawType.code.rawValue
        case .message: return RawType.message.rawValue
        case .detail: return RawType.detail.rawValue
        case .hint: return RawType.hint.rawValue
        case .position: return RawType.position.rawValue
        case .internalPosition: return RawType.internalPosition.rawValue
        case .internalQuery: return RawType.internalQuery.rawValue
        case .where: return RawType.where.rawValue
        case .schemaName: return RawType.schemaName.rawValue
        case .tableName: return RawType.tableName.rawValue
        case .columnName: return RawType.columnName.rawValue
        case .dataTypeName: return RawType.dataTypeName.rawValue
        case .constraintName: return RawType.constraintName.rawValue
        case .file: return RawType.file.rawValue
        case .line: return RawType.line.rawValue
        case .routine: return RawType.routine.rawValue
        case .unknown(let value): return value
        }
    }

    init(rawValue: Int) {
        guard let rawType = RawType(rawValue: rawValue) else {
            self = .unknown(rawValue)
            return
        }
        switch rawType {
        case .severity: self = .severity
        case .severityEN: self = .severityEN
        case .code: self = .code
        case .message: self = .message
        case .detail: self = .detail
        case .hint: self = .hint
        case .position: self = .position
        case .internalPosition: self = .internalPosition
        case .internalQuery: self = .internalQuery
        case .where: self = .where
        case .schemaName: self = .schemaName
        case .tableName: self = .tableName
        case .columnName: self = .columnName
        case .dataTypeName: self = .dataTypeName
        case .constraintName: self = .constraintName
        case .file: self = .file
        case .line: self = .line
        case .routine: self = .routine
        }
    }
}

extension BackendMessage.Error.Field: CustomStringConvertible {
    var description: String {
        return "(type: \(type), \"\(value)\")"
    }
}

extension BackendMessage.Error.Field.FieldType: CustomStringConvertible {
    var description: String {
        switch self {
        case .severity: return ".severity"
        case .severityEN: return ".severityEN"
        case .code: return ".code"
        case .message: return ".message"
        case .detail: return ".detail"
        case .hint: return ".hint"
        case .position: return ".position"
        case .internalPosition: return ".internalPosition"
        case .internalQuery: return ".internalQuery"
        case .where: return ".where"
        case .schemaName: return ".schemaName"
        case .tableName: return ".tableName"
        case .columnName: return ".columnName"
        case .dataTypeName: return ".dataTypeName"
        case .constraintName: return ".constraintName"
        case .file: return ".file"
        case .line: return ".line"
        case .routine: return ".routine"
        case .unknown(let value): return ".unknown(\(value))"
        }
    }
}
