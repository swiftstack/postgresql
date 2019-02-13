import Stream

extension StreamReader {
    func readCString() throws -> String {
        let value = try read(until: 0) { String(decoding: $0, as: UTF8.self) }
        try consume(count: 1)
        return value
    }
}

extension StreamWriter {
    func write(cString value: String) throws {
        try write(value)
        try write(UInt8(0))
    }
}
