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

import UIKit
import SpotifyLogin

class ViewController: UIViewController {

    @IBOutlet weak var loggedInStackView: UIStackView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            self?.loggedInStackView.alpha = (error == nil) ? 1.0 : 0.0
            if error != nil, token == nil {
                self?.showLoginFlow()
            }
        }
    }

    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }

    @IBAction func didTapLogOut(_ sender: Any) {
        SpotifyLogin.shared.logout()
        self.loggedInStackView.alpha = 0.0
        self.showLoginFlow()
    }

}
