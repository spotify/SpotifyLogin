//
//  Constants.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

enum Constants: String {
    case StreamingScope = "streaming"
    case PlaylistReadPrivateScope = "playlist-read-private"
    case PlaylistReadCollaborativeScope = "playlist-read-collaborative"
    case PlaylistModifyPublicScope = "playlist-modify-public"
    case PlaylistModifyPrivateScope = "playlist-modify-private"
    case UserFollowModifyScope = "user-follow-modify"
    case UserFollowReadScope = "user-follow-read"
    case UserLibraryReadScope = "user-library-read"
    case UserLibraryModifyScope = "user-library-modify"
    case UserReadTopScope = "user-top-read"
    case UserReadPrivateScope = "user-read-private"
    case UserReadBirthDateScope = "user-read-birthdate"
    case UserReadEmailScope = "user-read-email"
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
