//
//  Auth.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

public class Auth {

    public typealias AuthCallback = (Error?, Session?) -> ()

    public var clientID: String?
    public var clientSecret: String?
    public var redirectURL: URL?

    public var requestedScopes: [String]?
    internal var _session: Session?
    public var session: Session? {
        get {
            if _session == nil {
                return KeychainService.loadSession()
            }
            return _session
        }
        set {
            _session = newValue
            KeychainService.save(session: newValue)
        }
    }

    public static let sharedInstance = Auth()

    public func configure(clientID: String?, clientSecret: String?, redirectURL: URL?) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
    }

    public func loginURL(scopes: [String]?, responseType: String = "code", campaignID: String = Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: String = Constants.AuthServiceEndpointURL.rawValue) -> URL? {
        guard let clientID = self.clientID, let redirectURL = self.redirectURL, let scopes = scopes else {
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

    private func parse(url: URL) -> (code: String?, error: Bool) {
        var code: String?
        var error = false
        if let fragment = url.query {
            let fragmentItems = fragment.components(separatedBy: "&").reduce([String:String]()) { (dict, fragmentItem) in
                var mutableDict = dict
                let splitValue = fragmentItem.components(separatedBy: "=")
                mutableDict[splitValue[0]] = splitValue[1]
                return mutableDict
            }
            code = fragmentItems["code"]
            error = fragment.contains("error")
        }
        return (code: code, error: error)
    }

    public func handleAuthCallback(url: URL, callback: @escaping AuthCallback) {
        let parsedURL = parse(url: url)
        if parsedURL.error  {
            callback(AuthError.General, nil)
            return
        }

        if let code = parsedURL.code, let redirectURL = self.redirectURL, let authString = self.clientSecret?.data(using: .ascii)?.base64EncodedString(options: .endLineWithLineFeed) {
            let endpoint = URL(string: Constants.APITokenEndpointURL.rawValue)!
            var urlRequest = URLRequest(url: endpoint)
            let authHeaderValue = "Basic \(authString)"
            let requestBodyString = "code=\(code)&grant_type=authorization_code&redirect_uri=\(redirectURL)"
            urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/x-www-form-urlencoded" , forHTTPHeaderField: "content-type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = requestBodyString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
                if (error != nil) {
                    DispatchQueue.main.async {
                        callback(error, nil)
                    }
                    return
                }
                if let data = data, let authResponse = try? JSONDecoder().decode(APITokenEndpointResponse.self, from: data) {
                    self?.fetchUsername(accessToken: authResponse.access_token, completion: { (username) in
                        if let username = username {
                            let session = Session(userName: username, accessToken: authResponse.access_token, encryptedRefreshToken: authResponse.refresh_token, expirationDate: Date(timeIntervalSinceNow: authResponse.expires_in))
                            self?.session = session
                            DispatchQueue.main.async {
                                callback(nil, session)
                            }
                        }
                    })
                }
            })
            task.resume()
        }
    }

    private func fetchUsername(accessToken: String?, completion: @escaping (String?)->()){
        guard let accessToken = accessToken else {
            completion(nil)
            return
        }
        let profileURL = URL(string: Constants.ProfileServiceEndpointURL.rawValue)!
        var profileRequest = URLRequest(url: profileURL)
        let authHeaderValue = "Bearer \(accessToken)"
        profileRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: profileRequest, completionHandler: { (data, response, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if let data = data {
                let profileResponse = try? JSONDecoder().decode(ProfileEndpointResponse.self, from: data)
                completion(profileResponse?.id)
            }
        })
        task.resume()
    }

    public func renew(session: Session, endpointURL: URL, callback: @escaping AuthCallback) {
        guard let encryptedRefreshToken = session.encryptedRefreshToken else {
            callback(AuthError.NoRefreshToken, nil)
            return
        }
        let formDataString = "grant_type=refresh_token&refresh_token=\(encryptedRefreshToken)"
        var request = URLRequest(url: endpointURL)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = formDataString.data(using: .utf8)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    callback(error, nil)
                }
                return
            }
            if let data = data {
                var jsonObject: [String: Any]?
                do {
                    jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                }
                catch let error {
                    DispatchQueue.main.async {
                        callback(error, nil)
                    }
                }
                if let jsonObject = jsonObject {
                    //, let userID = jsonObject["id"] as? String {
                    //let session = Session(userName: userID, accessToken: session.accessToken, encryptedRefreshToken: nil, expirationDate: Date(timeIntervalSinceNow: Double(session.expiresIn)))
                    self.session = session
                    DispatchQueue.main.async {
                        callback(nil, session)
                    }
                }
            }
        })
        task.resume()

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
        return self.loginURL(scopes: self.requestedScopes, campaignID: Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: endpoint)
    }

}

struct APITokenEndpointResponse: Codable {
    let access_token: String
    let expires_in: Double
    let refresh_token: String
}

struct ProfileEndpointResponse: Codable {
    let id: String
}
