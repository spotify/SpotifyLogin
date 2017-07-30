//
//  LogInViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 2017-07-30.
//  Copyright © 2017 Spotify. All rights reserved.
//

import UIKit
import SpotifyLogin
import SafariServices

class LogInViewController: UIViewController, SFSafariViewControllerDelegate {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapLogIn(_ sender: Any) {
        SpotifyLogin.shared.login(from: self, scopes: [.Streaming, .UserReadTop, .PlaylistReadPrivate, .UserLibraryRead])
    }
}
