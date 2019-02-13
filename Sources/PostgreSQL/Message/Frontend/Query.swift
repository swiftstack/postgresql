import Stream

extension FrontendMessage {
    struct Query {
        let string: String

        init(_ string: String) throws {
            switch string.firstIndex(of: ";") {
            case .none:
                fatalError("the query must end with a semicolon;")
            case .some(let index):
                guard string.index(after: index) == string.endIndex else {
                    fatalError(
                        "sending several commands in one " +
                        "query is not supported yet")
                }
            }
            self.string = string
        }

        func encode(to stream: SubStreamWriter) throws {
            try stream.write(cString: string)
        }
    }
}
