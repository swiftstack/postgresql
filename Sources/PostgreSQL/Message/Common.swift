import Stream

protocol StreamEncodable {
    func encode(to stream: StreamWriter) throws
}

protocol StreamDecodable {
    func decode(from stream: StreamReader) throws
}
