//
//  Networking.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-07-29.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

//MARK: Constants

internal let AuthServiceEndpointURL = "https://accounts.spotify.com/"
internal let APITokenEndpointURL = "https://accounts.spotify.com/api/token"
internal let ProfileServiceEndpointURL = "https://api.spotify.com/v1/me"

//MARK: API responses

internal struct TokenEndpointResponse: Codable {
    let access_token: String
    let expires_in: Double
    let refresh_token: String?
}

internal struct ProfileEndpointResponse: Codable {
    let id: String
}

internal class SpotifyLoginNetworking {

    internal class func createSession(code: String, redirectURL: URL, clientSecret: String, completion: @escaping (Session?, Error?) -> ()) {
        let requestBody = "code=\(code)&grant_type=authorization_code&redirect_uri=\(redirectURL)"
        SpotifyLoginNetworking.authRequest(requestBody: requestBody, clientSecret: clientSecret) { (response, error) in
            if let response = response, error == nil {
                SpotifyLoginNetworking.profileUsernameRequest(accessToken: response.access_token, completion: { (username) in
                    if let username = username {
                        let session = Session(userName: username, accessToken: response.access_token, encryptedRefreshToken: response.refresh_token, expirationDate: Date(timeIntervalSinceNow: response.expires_in))
                        DispatchQueue.main.async {
                            completion(session, nil)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    internal class func renewSession(session: Session?, clientSecret: String, completion: @escaping (Session?, Error?) -> ()) {
        guard let session = session, let encryptedRefreshToken = session.encryptedRefreshToken else {
            DispatchQueue.main.async {
                completion(nil, LoginError.NoSession)
            }
            return
        }
        let requestBody = "grant_type=refresh_token&refresh_token=\(encryptedRefreshToken)"

        SpotifyLoginNetworking.authRequest(requestBody: requestBody, clientSecret: clientSecret) { (response, error) in
            if let response = response, error == nil {
                let session = Session(userName: session.userName, accessToken: session.accessToken, encryptedRefreshToken: response.refresh_token, expirationDate: Date(timeIntervalSinceNow: response.expires_in))
                DispatchQueue.main.async {
                    completion(session, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    //MARK: Private

    fileprivate class func profileUsernameRequest(accessToken: String?, completion: @escaping (String?)->()){
        guard let accessToken = accessToken else {
            completion(nil)
            return
        }
        let profileURL = URL(string: ProfileServiceEndpointURL)!
        var urlRequest = URLRequest(url: profileURL)
        let authHeaderValue = "Bearer \(accessToken)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, error == nil {
                let profileResponse = try? JSONDecoder().decode(ProfileEndpointResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(profileResponse?.id)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
        task.resume()
    }

    fileprivate class func authRequest(requestBody: String, clientSecret: String, completion: @escaping (TokenEndpointResponse?, Error?) -> ()){
        guard let authString = clientSecret.data(using: .ascii)?.base64EncodedString(options: .endLineWithLineFeed) else {
            DispatchQueue.main.async {
                completion(nil, LoginError.ConfigurationMissing)
            }
            return
        }
        let endpoint = URL(string: APITokenEndpointURL)!
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.addValue("application/x-www-form-urlencoded" , forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"

        let authHeaderValue = "Basic \(authString)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = requestBody.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, let authResponse = try? JSONDecoder().decode(TokenEndpointResponse.self, from: data), error == nil {
                DispatchQueue.main.async {
                    completion(authResponse, error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        })
        task.resume()

    }

}
