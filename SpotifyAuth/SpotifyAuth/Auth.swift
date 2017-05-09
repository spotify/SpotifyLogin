//
//  Auth.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

public enum AuthScope: String {
    case Streaming = "streaming"
    public enum Playlist: String {
        case ReadPrivate = "playlist-read-private"
        case ReadCollaborative = "playlist-read-collaborative"
        case ModifyPublic = "playlist-modify-public"
        case ModifyPrivate = "playlist-modify-private"
    }
    public enum User: String {
        case FollowRead = "user-follow-read"
        case LibraryRead = "user-library-read"
        case LibraryModify = "user-library-modify"
        case ReadPrivate = "user-read-private"
        case ReadTop = "user-top-read"
        case ReadBirthDate = "user-read-birthdate"
        case ReadEmail = "user-read-email"
    }
}

enum AuthError: Error {
    case General
}

public class Auth {

    public typealias AuthCallback = (Error?, Session?) -> ()

    public var clientID: String?
    public var redirectURL: URL?
    public var requestedScopes: [String]?
    public var session: Session?
    public var tokenSwapURL: URL?
    public var tokenRefreshURL: URL?

    public static let sharedInstance = Auth()

    public class func loginURL(clientID: String?, redirectURL: URL?, scopes: [String]?, responseType: String = "code", campaignID: String = Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: String = Constants.AuthServiceEndpointURL.rawValue) -> URL? {
        guard let clientID = clientID, let redirectURL = redirectURL, let scopes = scopes else {
            return nil
        }

        var params = [String: String]()
        params["client_id"] = clientID
        params["redirect_uri"] = redirectURL.absoluteString
        params["response_type"] = responseType
        params["show_dialog"] = "true"


        if (scopes.count > 0) {
            params["scope"] = scopes.joined(separator: " ")
        }

        params["nosignup"] = "true"
        params["nolinks"] = "true"

        params[Constants.AuthUTMSourceQueryKey.rawValue] = Constants.AuthUTMSourceQueryValue.rawValue
        params[Constants.AuthUTMMediumQueryKey.rawValue] = Constants.AuthUTMMediumCampaignQueryValue.rawValue
        params[Constants.AuthUTMCampaignQueryKey.rawValue] = campaignID

        let pairs = params.map{"\($0)=\($1)"}
        let pairsString = pairs.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ??  String()

        let loginPageURLString = "\(endpoint)authorize?\(pairsString)"
        return URL(string: loginPageURLString)
    }

    private func parse(url: URL) -> (authToken: String?, expiresIn: Int?, error: Bool) {
        var authToken: String?
        var expiresIn: Int?
        var error = false
        if let fragment = url.fragment {
            let fragmentItems = fragment.components(separatedBy: "&").reduce([String:String]()) { (dict, fragmentItem) in
                var mutableDict = dict
                let splitValue = fragmentItem.components(separatedBy: "=")
                mutableDict[splitValue[0]] = splitValue[1]
                return mutableDict
            }
            authToken = fragmentItems["access_token"]
            if let expiresInString = fragmentItems["expires_in"] {
                expiresIn = Int(expiresInString)
            }
            error = fragment.contains("error")
        }
        return (authToken: authToken, expiresIn: expiresIn, error: error)
    }

    public func handleAuthCallback(url: URL, callback: @escaping AuthCallback) {
        let parsedURL = parse(url: url)
        if parsedURL.error  {
            callback(AuthError.General, nil)
            return
        }

        if let accessToken = parsedURL.authToken, let expiresIn = parsedURL.expiresIn {
            let profileURL = URL(string: Constants.ProfileServiceEndpointURL.rawValue)!
            var profileRequest = URLRequest(url: profileURL)
            let authHeaderValue = "Bearer \(accessToken)"
            profileRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: profileRequest, completionHandler: { (data, response, error) in
                if (error != nil) {
                    callback(error, nil)
                    return
                }
                if let data = data {
                    var jsonObject: [String: Any]?
                    do {
                        jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    }
                    catch let error {
                        callback(error, nil)
                    }
                    if let jsonObject = jsonObject, let userID = jsonObject["id"] as? String {
                        let session = Session(userName: userID, accessToken: accessToken, encryptedRefreshToken: nil, expirationDate: Date(timeIntervalSinceNow: Double(expiresIn)))
                        self.session = session
                        callback(nil, session)
                    }
                }
            })
            task.resume()

        }
    }

    public class func supportsApplicationAuthentication() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: Constants.AppAuthURL.rawValue)!)
    }

    public class func spotifyApplicationIsInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "spotify:")!)
    }

    public func webAuthenticationURL() -> URL? {
        return authenticationURL(endpoint: Constants.AuthServiceEndpointURL.rawValue)
    }

    public func appAuthenticationURL() -> URL? {
        return authenticationURL(endpoint: Constants.AppAuthURL.rawValue)
    }

    public func canHandleURL(callbackURL: URL) -> Bool {
        guard let redirectURLString = redirectURL?.absoluteString else {
            return false
        }

        return callbackURL.absoluteString.hasPrefix(redirectURLString)
    }


    private func authenticationURL(endpoint: String) -> URL? {
        let responseType = (tokenSwapURL != nil) ? "code" : "token"
        return Auth.loginURL(clientID: self.clientID, redirectURL: self.redirectURL, scopes: self.requestedScopes, responseType: responseType, campaignID: Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: endpoint)
    }

}
