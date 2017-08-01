// Copyright (c) 2017 Spotify AB.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation


/// User scopes, specifying exactly what types of data the application wants to access.
public enum Scope: String {
    /// Read access to user's private playlists.
    case PlaylistReadPrivate = "playlist-read-private"
    /// Include collaborative playlists when requesting a user's playlists.
    case PlaylistReadCollaborative = "playlist-read-collaborative"
    /// Write access to a user's public playlists.
    case PlaylistModifyPublic = "playlist-modify-public"
    /// Write access to a user's private playlists.
    case PlaylistModifyPrivate = "playlist-modify-private"
    /// Control playback of a Spotify track. This scope is currently only available to Spotify native SDKs (for example, the iOS SDK and the Android SDK). The user must have a Spotify Premium account.
    case Streaming = "streaming"
    /// Write/delete access to the list of artists and other users that the user follows.
    case UserFollowModify = "user-follow-modify"
    /// Read access to the list of artists and other users that the user follows.
    case UserFollowRead = "user-follow-read"
    /// Write/delete access to a user's "Your Music" library.
    case UserLibraryModify = "user-library-modify"
    /// Read access to a user's "Your Music" library.
    case UserLibraryRead = "user-library-read"
    /// Read access to user’s subscription details (type of user account).
    case UserReadPrivate = "user-read-private"
    /// Read access to the user's birthdate.
    case UserReadBirthDate = "user-read-birthdate"
    /// Read access to user’s email address.
    case UserReadEmail = "user-read-email"
    /// Read access to a user's top artists and tracks.
    case UserReadTop = "user-top-read"
}
