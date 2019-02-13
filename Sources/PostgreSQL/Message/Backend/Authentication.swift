import Stream

extension BackendMessage {
    enum Authentication {
        case ok
        case clearTextPassword
        case md5Password

        enum RawType: UInt32 {
            case ok                = 0
            case kerberos          = 2
            case clearTextPassword = 3
            case md5Password       = 5
            case scmCredential     = 6
            case gss               = 7
            case sspi              = 9
            case gssContinue       = 8
            case sasl              = 10
            case saslContinue      = 11
            case saslFinal         = 12
        }

        init(from stream: SubStreamReader) throws {
            guard stream.limit == 4 else {
                fatalError("Authentication: invalid size")
            }
            let rawType = try stream.read(UInt32.self)
            guard let status = RawType(rawValue: rawType) else {
                fatalError("Authentication: unknown status \(rawType)")
            }
            switch status {
            case .ok: self = .ok
            // case .clearTextPassword: self = .clearTextPassword
            // case .md5Password: self = .md5Password
            default: fatalError("Authentication: unsupported method: \(status)")
            }
        }
    }
}
