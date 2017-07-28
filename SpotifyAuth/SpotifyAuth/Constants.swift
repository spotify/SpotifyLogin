//
//  Constants.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

public enum Constants: String {
    case UserFollowModifyScope = "user-follow-modify"
    case ErrorDomain = "com.spotify.auth"
    case AuthServiceEndpointURL = "https://accounts.spotify.com/"
    case APITokenEndpointURL = "https://accounts.spotify.com/api/token"
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

public enum AuthScope: String {
    case Streaming = "streaming"
    public enum Playlist: String {
        case ReadPrivate = "playlist-read-private"
        case ReadCollaborative = "playlist-read-collaborative"
        case ModifyPublic = "playlist-modify-public"
        case ModifyPrivate = "playlist-modify-private"
    }
    public enum User: String {
        case FollowRead = "user-follow-read"
        case LibraryRead = "user-library-read"
        case LibraryModify = "user-library-modify"
        case ReadPrivate = "user-read-private"
        case ReadTop = "user-top-read"
        case ReadBirthDate = "user-read-birthdate"
        case ReadEmail = "user-read-email"
    }
}

public enum AuthError: Error {
    case General
    case NoRefreshToken
}
