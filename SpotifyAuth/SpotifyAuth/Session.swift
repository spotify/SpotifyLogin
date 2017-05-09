import Foundation

public struct Session {
    let userName: String
    public let accessToken: String
    var encryptedRefreshToken: String? = nil
    let expirationDate: Date

    public func isValid() -> Bool {
        return Date().compare(self.expirationDate) == .orderedAscending
    }

    public func archive() -> Data {
        var sessionCopy = self
        return Data(bytes: &sessionCopy, count: MemoryLayout<Session>.stride)
    }

    public static func unarchive(data: Data) -> Session? {
        guard data.count == MemoryLayout<Session>.stride else {
            fatalError("Invalid memory layout")
        }

        var session: Session?
        data.withUnsafeBytes { (bytes) -> Void in
            session = UnsafePointer<Session>(bytes).pointee
        }
        return session
    }
}
