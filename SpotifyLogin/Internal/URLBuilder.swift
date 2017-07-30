//
//  URLBuilder.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-07-30.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

internal class URLBuilder {

    let clientID: String
    let clientSecret: String
    let redirectURL: URL

    // MARK: Lifecycle

    internal init(clientID: String, clientSecret: String, redirectURL: URL) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
    }

    // MARK: URL functions

    internal func authenticationURL(type: AuthenticationURLType, scopes: [Scope]) -> URL? {
        let endpoint = type.rawValue
        let scopeStrings = scopes.map({$0.rawValue})

        var params = ["client_id": clientID, "redirect_uri": redirectURL.absoluteString, "response_type": "code", "show_dialog": "true", "nosignup": "true", "nolinks": "true", "utm_source": Constants.AuthUTMSourceQueryValue, "utm_medium": Constants.AuthUTMMediumCampaignQueryValue, "utm_campaign": Constants.AuthUTMMediumCampaignQueryValue]

        if (scopeStrings.count > 0) {
            params["scope"] = scopeStrings.joined(separator: " ")
        }

        let pairs = params.map{"\($0)=\($1)"}
        let pairsString = pairs.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ??  String()

        let loginPageURLString = "\(endpoint)authorize?\(pairsString)"
        return URL(string: loginPageURLString)
    }

    internal func parse(url: URL) -> (code: String?, error: Bool) {
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
        if !error && code == nil {
            error = true
        }
        return (code: code, error: error)
    }

    internal func canHandleURL(_ url: URL) -> Bool {
        let redirectURLString = redirectURL.absoluteString
        return url.absoluteString.hasPrefix(redirectURLString)
    }

}

internal enum AuthenticationURLType: String {
    case App = "spotify-action://"
    case Web = "https://accounts.spotify.com/"
}
