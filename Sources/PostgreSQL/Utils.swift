import Stream

extension StreamReader {
    func readCString() async throws -> String {
        let value = try await read(until: 0) { String(decoding: $0, as: UTF8.self) }
        try await consume(count: 1)
        return value
    }
}

extension StreamWriter {
    func write(cString value: String) async throws {
        try await write(value)
        try await write(UInt8(0))
    }
}
