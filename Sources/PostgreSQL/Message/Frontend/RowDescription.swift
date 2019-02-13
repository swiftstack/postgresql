import Stream

struct RowDescription {
    let columns: [ColumnDescription]

    var columnNames: [String] {
        return columns.map{ $0.name }
    }

    init(from stream: SubStreamReader) throws {
        var columns = [ColumnDescription]()
        var numberOfFields = Int(try stream.read(UInt16.self))
        while !stream.isEmpty {
            columns.append(try .init(from: stream))
            numberOfFields -= 1
        }
        guard numberOfFields == 0 else {
            fatalError("RowDescription: invalid format")
        }
        self.columns = columns
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

    init(from stream: SubStreamReader) throws {
        self.name = try stream.readCString()
        self.origin = .init(
            tableId: Int(try stream.read(Int32.self)),
            columnNumber: Int(try stream.read(Int16.self)))
        self.dataType = .init(
            id: Int(try stream.read(Int32.self)),
            size: Int(try stream.read(Int16.self)),
            modifier: Int(try stream.read(Int32.self)))
        self.format = Format(rawValue: try stream.read(Int16.self))
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