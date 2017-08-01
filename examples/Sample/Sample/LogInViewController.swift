//
//  LogInViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 2017-07-30.
//  Copyright © 2017 Spotify. All rights reserved.
//

import UIKit
import SpotifyLogin

class LogInViewController: UIViewController {

    var loginButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = SpotifyLogin.shared.loginButton(from: self, scopes: [.Streaming, .UserReadTop, .PlaylistReadPrivate, .UserLibraryRead])
        self.view.addSubview(button)
        self.loginButton = button
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccessful), name: .SpotifyLoginSuccessful, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton?.center = self.view.center
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func loginSuccessful() {
        self.navigationController?.popViewController(animated: true)
    }
}
