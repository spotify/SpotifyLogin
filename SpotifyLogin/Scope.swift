//
//  Scopes.swift
//  SpotifyLogin
//
//  Created by Roy Marmelstein on 2017-07-30.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation


/// User scopes, specifying exactly what types of data the application wants to access.
///
/// - PlaylistReadPrivate: Read access to user's private playlists.
/// - PlaylistReadCollaborative: Include collaborative playlists when requesting a user's playlists.
/// - PlaylistModifyPublic: Write access to a user's public playlists.
/// - PlaylistModifyPrivate: Write access to a user's private playlists.
/// - Streaming: Control playback of a Spotify track. This scope is currently only available to Spotify native SDKs (for example, the iOS SDK and the Android SDK). The user must have a Spotify Premium account.
/// - UserFollowModify: Write/delete access to the list of artists and other users that the user follows.
/// - UserFollowRead: Read access to the list of artists and other users that the user follows.
/// - UserLibraryModify: Write/delete access to a user's "Your Music" library.
/// - UserLibraryRead: Read access to a user's "Your Music" library.
/// - UserReadPrivate: Read access to user’s subscription details (type of user account).
/// - UserReadBirthDate: Read access to the user's birthdate.
/// - UserReadEmail: Read access to user’s email address.
/// - UserReadTop: Read access to a user's top artists and tracks.
public enum Scope: String {
    case PlaylistReadPrivate = "playlist-read-private"
    case PlaylistReadCollaborative = "playlist-read-collaborative"
    case PlaylistModifyPublic = "playlist-modify-public"
    case PlaylistModifyPrivate = "playlist-modify-private"
    case Streaming = "streaming"
    case UserFollowModify = "user-follow-modify"
    case UserFollowRead = "user-follow-read"
    case UserLibraryModify = "user-library-modify"
    case UserLibraryRead = "user-library-read"
    case UserReadPrivate = "user-read-private"
    case UserReadBirthDate = "user-read-birthdate"
    case UserReadEmail = "user-read-email"
    case UserReadTop = "user-top-read"
}
