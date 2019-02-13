import Stream

public struct DataRow {
    public let values: [String]

    init(from stream: SubStreamReader) throws {
        var values = [String]()

        var fieldsCount = Int(try stream.read(Int16.self))
        while fieldsCount > 0 {
            let length = Int(try stream.read(Int32.self))
            values.append(try stream.read(count: length, as: String.self))
            fieldsCount -= 1
        }

        self.values = values
    }
}

extension DataRow: CustomStringConvertible {
    public var description: String {
        return "\(values)"
    }
}
