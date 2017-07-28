Spotify Swift Authentication Framework
=======

Usage of this Framework is bound under the [Developer Terms of Use](https://developer.spotify.com/developer-terms-of-use/).

Getting Started
=======

[Spotify Developer Portal](https://developer.spotify.com/technologies/spotify-ios-sdk/) | [API Reference](https://spotify.github.io/ios-sdk/)


This framework contains functionality pertaining to authentication of the user:

* Managing the authentication session.
* Branding.
* Single Sign-On.

Authenticating and Scopes
=======

You can generate your application's Client ID, Client Secret and define your
callback URIs at the [My Applications](https://developer.spotify.com/my-applications/)
section of the Spotify Developer Website. The temporary keys given out for previous
SDK Releases will not work with Beta 3 and newer.

When connecting a user to your app, you *must* provide the scopes your application
needs to operate. A scope is a permission to access a certain part of a user's account,
and if you don't ask for the scopes you need you will receive permission denied errors
when trying to perform various tasks.

You do *not* need a scope to access non-user specific information, such as to perform
searches, look up metadata, etc.

Common scopes include:

* `SPTAuthStreamingScope` allows music streaming for Premium users.

* `SPTAuthUserReadPrivateScope` allows access to a user's private information, such
as full display name, user photo, etc.

* `SPTAuthPlaylistReadScope` and `SPTAuthPlaylistReadPrivateScope` allows access to
a user's public and private playlists, respectively.

* `SPTAuthPlaylistModifyScope` and `SPTAuthPlaylistModifyPrivateScope` allows
modification of a user's public and private playlists, respectively.

A full list of scopes is available in the documentation and in `SPTAuth.h`.

If your application's scope needs change after a user is connected to your app, you
will need to throw out your stored credentials and re-authenticate the user with the
new scopes.

**Important:** Only ask for the scopes your application needs. Requesting playlist
access when your app doesn't use playlists, for example, is bad form.

Session Lifetime
=======

Once your user is authenticated, you will receive an `SPTSession` object that allows
you to perform authenticated requests. This session is only valid for a certain
period of time, and must be refreshed.

You can find out if the session is still valid by calling the `-isValid` method on
`SPTSession`, and the expiration date using the `expirationDate` property. Once
the session is no longer valid, you can renew it using `SPTAuth`'s
`-renewSession:withServiceEndpointAtURL:callback:` method.

As an example, when your application is launched you'll want to restore your stored
session then check if it's valid and renew it if necessary. Your code flow would go
something like this:
