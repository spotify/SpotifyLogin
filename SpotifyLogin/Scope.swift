//
//  Scopes.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-07-30.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

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
