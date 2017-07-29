//
//  Constants.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

internal struct Constants{
    static let ErrorDomain = "com.spotify.auth"
    static let AppAuthURL = "spotify-action://"
    static let AuthJSONErrorKey = "error"
    static let AuthJSONErrorDescriptionKey = "error_description"
    static let AuthUTMSourceQueryKey = "utm_source"
    static let AuthUTMMediumQueryKey = "utm_medium"
    static let AuthUTMCampaignQueryKey = "utm_campaign"
    static let AuthUTMSourceQueryValue = "spotify-sdk"
    static let AuthUTMMediumCampaignQueryValue = "ios-sdk"
}

public enum Scope: String {
    case Streaming = "streaming"
    case PlaylistReadPrivate = "playlist-read-private"
    case PlaylistReadCollaborative = "playlist-read-collaborative"
    case PlaylistModifyPublic = "playlist-modify-public"
    case PlaylistModifyPrivate = "playlist-modify-private"
    case UserFollowRead = "user-follow-read"
    case UserFollowModify = "user-follow-modify"
    case UserLibraryRead = "user-library-read"
    case UserLibraryModify = "user-library-modify"
    case UserReadPrivate = "user-read-private"
    case UserReadTop = "user-top-read"
    case UserReadBirthDate = "user-read-birthdate"
    case UserReadEmail = "user-read-email"
}

public enum LoginError: Error {
    case General
    case ConfigurationMissing
    case RefreshFailed
    case NoSession
    case InvalidUrl
}
