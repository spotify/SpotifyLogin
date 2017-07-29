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

}
