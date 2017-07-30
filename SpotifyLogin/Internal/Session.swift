import Foundation

internal struct Session: Codable {
    let userName: String
    let accessToken: String
    var encryptedRefreshToken: String? = nil
    let expirationDate: Date

    internal func isValid() -> Bool {
        return Date().compare(self.expirationDate) == .orderedAscending
    }
}
