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
