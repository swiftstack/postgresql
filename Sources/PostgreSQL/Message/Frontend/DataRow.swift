import Stream

public struct DataRow {
    public let values: [String]

    static func decode(from stream: SubStreamReader) async throws -> Self {
        var values = [String]()

        var fieldsCount = Int(try await stream.read(Int16.self))
        while fieldsCount > 0 {
            let length = Int(try await stream.read(Int32.self))
            values.append(try await stream.read(count: length, as: String.self))
            fieldsCount -= 1
        }

        return .init(values: values)
    }
}

extension DataRow: CustomStringConvertible {
    public var description: String {
        return "\(values)"
    }
}
