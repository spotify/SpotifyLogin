//
//  SpotifyLogin.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation
import SafariServices

/// Spotify login object.
public class SpotifyLogin {

    /// Shared instance.
    public static let shared = SpotifyLogin()

    private var clientID: String?
    private var clientSecret: String?
    private var redirectURL: URL?
    private var _session: Session?
    private var session: Session? {
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

    // MARK: Interface

    /// Configure login object.
    ///
    /// - Parameters:
    ///   - clientID: App's client id.
    ///   - clientSecret: App's client secret.
    ///   - redirectURL: App's redirect url.
    ///   - requestedScopes: Requested scopes.
    public func configure(clientID: String, clientSecret: String, redirectURL: URL) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
    }


    /// Asynchronous call to retrieve the session's auth token. Automatically refreshes if auth token expired. 
    ///
    /// - Parameter completion: Returns the auth token as a string if available and an optional error.
    public func getAccessToken(completion:@escaping (String?, Error?) -> ()) {
        // If the login object is not fully configured, return an error
        guard clientID != nil, redirectURL != nil, let clientSecret = self.clientSecret else {
            completion(nil, LoginError.ConfigurationMissing)
            return
        }
        // If there is no session, return an error
        guard let session = self.session else {
            completion(nil, LoginError.NoSession)
            return
        }
        // If session is valid return access token, otherwsie refresh
        if session.isValid() {
            completion(session.accessToken, nil)
            return
        } else {
            SpotifyLoginNetworking.renewSession(session: session, clientSecret: clientSecret, completion: { (session, error) in
                if let session = session, error == nil {
                    completion(session.accessToken, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }


    /// Trigger log in flow.
    ///
    /// - Parameter viewController: The view controller that orignates the log in flow.
    public func login(from viewController: UIViewController, scopes:[Scope]) {
        let scopeStrings = scopes.map({$0.rawValue})
        if let appAuthenticationURL = appAuthenticationURL(scopes: scopeStrings), UIApplication.shared.canOpenURL(appAuthenticationURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appAuthenticationURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appAuthenticationURL)
            }
        } else if let webAuthenticationURL = webAuthenticationURL(scopes: scopeStrings) {
            viewController.definesPresentationContext = true
            let safariVC: SFSafariViewController = SFSafariViewController(url: webAuthenticationURL)
       //     safariVC.delegate = viewController
            safariVC.modalPresentationStyle = .pageSheet
            viewController.present(safariVC, animated: true, completion: nil)
        } else {
            assertionFailure("Unable to login.")
        }
    }

    /// Process URL and attempts to create a session.
    ///
    /// - Parameters:
    ///   - url: url to handle.
    ///   - completion: Returns an optional error or nil if successful.
    /// - Returns: Whether or not the URL was handled.
    public func applicationOpenURL(_ url: URL, completion: @escaping (Error?) -> ()) -> Bool {
        guard canHandleURL(url) else {
            return false
        }

        guard let redirectURL = self.redirectURL, let clientSecret = self.clientSecret else {
            completion(LoginError.ConfigurationMissing)
            return false
        }

        let parsedURL = parse(url: url)
        if let code = parsedURL.code, !parsedURL.error  {
            SpotifyLoginNetworking.createSession(code: code, redirectURL: redirectURL, clientSecret: clientSecret, completion: { [weak self] (session, error) in
                if error == nil {
                    self?.session = session
                }
                completion(error)
            })
        } else {
            completion(LoginError.InvalidUrl)
        }
        return true
    }

    // MARK: Private

    private func webAuthenticationURL(scopes: [String]) -> URL? {
        return loginURL(scopes: scopes, endpoint: AuthServiceEndpointURL)
    }

    private func appAuthenticationURL(scopes: [String]) -> URL? {
        return loginURL(scopes: scopes, endpoint: Constants.AppAuthURL)
    }

    private func loginURL(scopes: [String]?, endpoint: String) -> URL? {
        guard let clientID = self.clientID, let redirectURL = self.redirectURL, let scopes = scopes else {
            return nil
        }

        var params = ["client_id": clientID, "redirect_uri": redirectURL.absoluteString, "response_type": "code", "show_dialog": "true", "nosignup": "true", "nolinks": "true", "utm_source": Constants.AuthUTMSourceQueryValue, "utm_medium": Constants.AuthUTMMediumCampaignQueryValue, "utm_campaign": Constants.AuthUTMMediumCampaignQueryValue]

        if (scopes.count > 0) {
            params["scope"] = scopes.joined(separator: " ")
        }

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

    /// Check if SpotifyLogin can handle a url.
    ///
    /// - Parameter url: URL to process.
    /// - Returns: Whether or not SpotifyLogin can handle a given url.
    private func canHandleURL(_ url: URL) -> Bool {
        guard let redirectURLString = redirectURL?.absoluteString else {
            return false
        }
        return url.absoluteString.hasPrefix(redirectURLString)
    }

}
