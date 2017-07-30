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

    /// The userName for the current session.
    public var userName: String? {
        get {
            return self.session?.userName
        }
    }

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

    weak private var safariVC: SFSafariViewController?


    private var urlBuilder: URLBuilder?

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
        self.urlBuilder = URLBuilder(clientID: clientID, clientSecret: clientSecret, redirectURL: redirectURL)
    }


    /// Asynchronous call to retrieve the session's auth token. Automatically refreshes if auth token expired. 
    ///
    /// - Parameter completion: Returns the auth token as a string if available and an optional error.
    public func getAccessToken(completion:@escaping (String?, Error?) -> ()) {
        // If the login object is not fully configured, return an error
        guard redirectURL != nil, let clientID = self.clientID, let clientSecret = self.clientSecret else {
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
            Networking.renewSession(session: session, clientID: clientID, clientSecret: clientSecret, completion: { (session, error) in
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
    public func login(from viewController: (UIViewController), scopes:[Scope]) {
        if let appAuthenticationURL = urlBuilder?.authenticationURL(type: .App, scopes: scopes), UIApplication.shared.canOpenURL(appAuthenticationURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appAuthenticationURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appAuthenticationURL)
            }
        } else if let webAuthenticationURL = urlBuilder?.authenticationURL(type: .Web, scopes: scopes) {
            viewController.definesPresentationContext = true
            let safariViewController: SFSafariViewController = SFSafariViewController(url: webAuthenticationURL)
            safariViewController.modalPresentationStyle = .pageSheet
            safariViewController.delegate = SafariDelegate()
            viewController.present(safariViewController, animated: true, completion: nil)
            self.safariVC = safariViewController
        } else {
            assertionFailure("Unable to login.")
        }
    }


    /// Log out of current session.
    public func logout() {
        if let userName = UserDefaults.standard.value(forKey: Constants.KeychainUsernameKey) {
            let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPasswordValue,
                                                kSecAttrServiceValue: Constants.KeychainServiceValue,
                                                kSecAttrAccountValue: userName,
                                                kSecReturnDataValue: kCFBooleanTrue,
                                                kSecMatchLimitValue: kSecMatchLimitOneValue]
            SecItemDelete(keychainQuery as CFDictionary)
        }
        UserDefaults.standard.removeObject(forKey: Constants.KeychainUsernameKey)
        self.session = nil
    }

    /// Process URL and attempts to create a session.
    ///
    /// - Parameters:
    ///   - url: url to handle.
    ///   - completion: Returns an optional error or nil if successful.
    /// - Returns: Whether or not the URL was handled.
    public func applicationOpenURL(_ url: URL, completion: @escaping (Error?) -> ()) -> Bool {
        guard let urlBuilder = self.urlBuilder, let redirectURL = self.redirectURL, let clientID = self.clientID, let clientSecret = self.clientSecret else {
            DispatchQueue.main.async {
                completion(LoginError.ConfigurationMissing)
            }
            return false
        }

        guard urlBuilder.canHandleURL(url) else {
            DispatchQueue.main.async {
                completion(LoginError.InvalidUrl)
            }
            return false
        }

        self.safariVC?.dismiss(animated: true, completion: nil)

        let parsedURL = urlBuilder.parse(url: url)
        if let code = parsedURL.code, !parsedURL.error  {
            Networking.createSession(code: code, redirectURL: redirectURL, clientID: clientID, clientSecret: clientSecret, completion: { [weak self] (session, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        NotificationCenter.default.post(name: .SpotifyLoginSuccessful, object: nil)
                        self?.session = session
                    }
                    completion(error)
                }
            })
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .SpotifyLoginSuccessful, object: nil)
                completion(LoginError.InvalidUrl)
            }
        }
        return true
    }

}

/// Login error
public enum LoginError: Error {
    /// Generic error message.
    case General
    /// Spotify Login is not fully configured. Use the configuration function.
    case ConfigurationMissing
    /// There is no valid session. Use the login function.
    case NoSession
    /// The url provided to the app can not be handled or parsed.
    case InvalidUrl
}

public extension Notification.Name {
    /// A Notification that is emitted by SpotifyLogin after a successful login. Can be used to update the UI.
    public static let SpotifyLoginSuccessful = Notification.Name("SpotifyLoginSuccessful")
}

