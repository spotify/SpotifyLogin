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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let clientID: String = "c688d464ba41449c8fe005737c6e26f3"
        let clientSecret: String = "c688d464ba41449c8fe005737c6e26f3:e413483215ed4f918582e9361ee8ace0"
        let redirectURL: URL = URL(string:"labcaviar://")!
        SpotifyLogin.shared.configure(clientID: clientID, clientSecret: clientSecret, redirectURL: redirectURL)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (SpotifyLogin.shared.canHandleURL(url)) {
            DispatchQueue.main.async {
                SpotifyLogin.shared.handleRedirectURL(url, callback: { (error) in
                })
            }
            return true
        }
        return false
    }


}

