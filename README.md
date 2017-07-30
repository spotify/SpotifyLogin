# SpotifyLogin
SpotifyLogin is a Swift 4 Framework for authenticating with the Spotify API.

Usage of this Framework is bound under the [Developer Terms of Use](https://developer.spotify.com/developer-terms-of-use/).

## Usage

### Pre-requisites
You will need to register your app in the [Developer Portal](https://developer.spotify.com/my-applications/#!/applications).

To proceed, you will need a unique redirect url, a client ID and a client secret. 

Make sure to put in your bundle ID from your app.

### Set up SwiftLogin

Set up SwiftLogin using any of the methods detailed below (Cocoapods / Carthage / manually).

### Set up info.plist

Under Target/info, create new URL type.
Add the app's identifer as the *Identifier* and the redirect url scheme in *URL schemes*.

### Set up your AppDelegate

Add the following to your app delegate:

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SpotifyLogin.shared.configure(clientID: <#T##String#>, clientSecret: <#T##String#>, redirectURL: <#T##URL#>)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { (error) in }
        return handled
    }
```

### Check if a user is logged in.

You can retrieve an access token and check if a user is logged in by:

```swift
        SpotifyLogin.shared.getAccessToken { [weak self](token, error) in
            if error != nil {
	            // User is not logged in, show log in flow.
            }
        }
```

This also automatically takes care of renewing expired tokens. 

### Log in / Log out

To log in:

```swift
        SpotifyLogin.shared.login(from: self, scopes: [.Streaming, .UserReadTop, .PlaylistReadPrivate, .UserLibraryRead])
```

The scopes define the set of permissions your app will be able to use. For more information about available scopes, see [Scopes Documentation](https://developer.spotify.com/web-api/using-scopes/)

To log out:

```swift
        SpotifyLogin.shared.logout()
```


## Additional information

[Spotify Developer Portal](https://developer.spotify.com/technologies/spotify-ios-sdk/) | [API Reference](https://spotify.github.io/ios-sdk/)
