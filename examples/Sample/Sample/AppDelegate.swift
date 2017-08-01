//
//  AppDelegate.swift
//  Sample
//
//  Created by Roy Marmelstein on 2017-07-29.
//  Copyright © 2017 Spotify. All rights reserved.
//

import UIKit
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let clientID: String = "df460a7d1ff04a72ba9699ca76cfe69b"
        let clientSecret: String = "e47aa575e3244c4b96a6f569b1f59f63"
        let redirectURL: URL = URL(string:"loginsample://")!
        SpotifyLogin.shared.configure(clientID: clientID, clientSecret: clientSecret, redirectURL: redirectURL)
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { (error) in }
        return handled
    }

}
