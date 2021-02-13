import Stream

struct RowDescription {
    let columns: [ColumnDescription]

    var columnNames: [String] {
        return columns.map{ $0.name }
    }

    static func decode(from stream: SubStreamReader) async throws -> Self {
        var columns = [ColumnDescription]()
        var numberOfFields = Int(try await stream.read(UInt16.self))
        while !stream.isEmpty {
            columns.append(try await .decode(from: stream))
            numberOfFields -= 1
        }
        guard numberOfFields == 0 else {
            fatalError("RowDescription: invalid format")
        }
        return .init(columns: columns)
    }
}

struct ColumnDescription {
    let name: String
    let origin: Origin?
    let dataType: DataType
    let format: Format?

    struct Origin {
        let tableId: Int
        let columnNumber: Int
    }

    struct DataType {
        let id: Int
        let size: Int
        let modifier: Int
    }

    enum Format: Int16 {
        case text   = 0
        case binary = 1
    }

    static func decode(from stream: SubStreamReader) async throws -> Self {
        let name = try await stream.readCString()
        let origin: Origin = .init(
            tableId: Int(try await stream.read(Int32.self)),
            columnNumber: Int(try await stream.read(Int16.self)))
        let dataType: DataType = .init(
            id: Int(try await stream.read(Int32.self)),
            size: Int(try await stream.read(Int16.self)),
            modifier: Int(try await stream.read(Int32.self)))
        let format = Format(rawValue: try await stream.read(Int16.self))
        return .init(
            name: name,
            origin: origin,
            dataType: dataType,
            format: format)
    }
}

extension RowDescription: CustomStringConvertible {
    var description: String {
        return "\(columnNames)"
    }
}

extension ColumnDescription: CustomStringConvertible {
    var description: String {
        var result = #"ColumnDescription(name: "\#(name)""#
        if let origin = origin {
            result.append(", origin: \(origin)")
        }
        result.append(", dataType: \(dataType)")
        if let format = format {
            result.append(", format: \(format)")
        }
        result.append(")")
        return result
    }
}

extension ColumnDescription.Origin: CustomStringConvertible {
    var description: String {
        return "Origin(tableId: \(tableId), columnNumber: \(columnNumber))"
    }
}

extension ColumnDescription.DataType: CustomStringConvertible {
    var description: String {
        return "DataType(id: \(id), size: \(size), modifier: \(modifier))"
    }
}

extension ColumnDescription.Format: CustomStringConvertible {
    var description: String {
        switch self {
        case .binary: return ".binary"
        case .text: return ".text"
        }
    }
}
