//
//  Auth.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation


enum AuthScope: String {
    case Streaming
    enum Playlist: String {
        case ReadPrivate
        case ReadCollaborative
        case ModifyPublic
        case ModifyPrivate
    }
    enum User: String {
        case FollowRead
        case LibraryRead
        case LibraryModify
        case ReadPrivate
        case ReadTop
        case ReadBirthDate
        case ReadEmail
    }
}


public class Auth {

    var clientID: String?
    var redirectURL: URL?
    var requestedScopes: [String]?
    var session: Session?
    var tokenSwapURL: URL?
    var tokenRefreshURL: URL?

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
        let loginPageURLString = "\(endpoint)authorize?\(pairs.joined(separator: "&"))"
        let escapedString = loginPageURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ??  String()

        return URL(string: escapedString)
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
