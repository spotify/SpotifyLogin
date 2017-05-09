//
//  Constants.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

enum Constants: String {
    case UserFollowModifyScope = "user-follow-modify"
    case ErrorDomain = "com.spotify.auth"
    case AuthServiceEndpointURL = "https://accounts.spotify.com/"
    case ProfileServiceEndpointURL = "https://api.spotify.com/v1/me"
    case AppAuthURL = "spotify-action://"
    case AuthJSONErrorKey = "error"
    case AuthJSONErrorDescriptionKey = "error_description"
    case AuthUTMSourceQueryKey = "utm_source"
    case AuthUTMMediumQueryKey = "utm_medium"
    case AuthUTMCampaignQueryKey = "utm_campaign"
    case AuthUTMSourceQueryValue = "spotify-sdk"
    case AuthUTMMediumCampaignQueryValue = "ios-sdk"
}
