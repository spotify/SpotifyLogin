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

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccessful), name: .SpotifyLoginSuccessful, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func loginSuccessful() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func didTapLogIn(_ sender: Any) {
        SpotifyLogin.shared.login(from: self, scopes: [.Streaming, .UserReadTop, .PlaylistReadPrivate, .UserLibraryRead])
    }
}
