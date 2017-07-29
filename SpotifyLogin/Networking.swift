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

    internal class func fetchUsername(accessToken: String?, completion: @escaping (String?)->()){
        guard let accessToken = accessToken else {
            completion(nil)
            return
        }
        let profileURL = URL(string: ProfileServiceEndpointURL)!
        var urlRequest = URLRequest(url: profileURL)
        let authHeaderValue = "Bearer \(accessToken)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
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

    internal class func createSession(code: String, redirectURL: URL, clientSecret: String, completion: @escaping (Session?, Error?) -> ()) {
        guard let authString = clientSecret.data(using: .ascii)?.base64EncodedString(options: .endLineWithLineFeed) else {
            completion(nil, LoginError.ConfigurationMissing)
            return
        }

        let endpoint = URL(string: APITokenEndpointURL)!
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.addValue("application/x-www-form-urlencoded" , forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"

        let authHeaderValue = "Basic \(authString)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        let requestBodyString = "code=\(code)&grant_type=authorization_code&redirect_uri=\(redirectURL)"
        urlRequest.httpBody = requestBodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, let authResponse = try? JSONDecoder().decode(TokenEndpointResponse.self, from: data), error == nil {
                SpotifyLoginNetworking.fetchUsername(accessToken: authResponse.access_token, completion: { (username) in
                    if let username = username {
                        let session = Session(userName: username, accessToken: authResponse.access_token, encryptedRefreshToken: authResponse.refresh_token, expirationDate: Date(timeIntervalSinceNow: authResponse.expires_in))
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
        })
        task.resume()
    }


}
