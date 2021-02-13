import Stream

protocol StreamEncodable {
    func encode(to stream: StreamWriter) async throws
}

protocol StreamDecodable {
    func decode(from stream: StreamReader) async throws
}
