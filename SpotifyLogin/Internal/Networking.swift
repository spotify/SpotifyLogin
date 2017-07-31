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

//MARK: Constants

internal let APITokenEndpointURL = "https://accounts.spotify.com/api/token"
internal let ProfileServiceEndpointURL = "https://api.spotify.com/v1/me"

//MARK: API responses

internal struct TokenEndpointResponse: Codable {
    let access_token: String
    let expires_in: Double
    let refresh_token: String?
}

internal struct ProfileEndpointResponse: Codable {
    let id: String
}

internal class Networking {

    internal class func createSession(code: String, redirectURL: URL, clientID: String, clientSecret: String, completion: @escaping (Session?, Error?) -> ()) {
        let requestBody = "code=\(code)&grant_type=authorization_code&redirect_uri=\(redirectURL.absoluteString)"
        Networking.authRequest(requestBody: requestBody, clientID: clientID, clientSecret: clientSecret) { (response, error) in
            if let response = response, error == nil {
                Networking.profileUsernameRequest(accessToken: response.access_token, completion: { (username) in
                    if let username = username {
                        let session = Session(userName: username, accessToken: response.access_token, encryptedRefreshToken: response.refresh_token, expirationDate: Date(timeIntervalSinceNow: response.expires_in))
                        DispatchQueue.main.async {
                            completion(session, nil)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    internal class func renewSession(session: Session?, clientID: String, clientSecret: String, completion: @escaping (Session?, Error?) -> ()) {
        guard let session = session, let encryptedRefreshToken = session.encryptedRefreshToken else {
            DispatchQueue.main.async {
                completion(nil, LoginError.NoSession)
            }
            return
        }
        let requestBody = "grant_type=refresh_token&refresh_token=\(encryptedRefreshToken)"

        Networking.authRequest(requestBody: requestBody, clientID: clientID, clientSecret: clientSecret) { (response, error) in
            if let response = response, error == nil {
                let session = Session(userName: session.userName, accessToken: session.accessToken, encryptedRefreshToken: response.refresh_token, expirationDate: Date(timeIntervalSinceNow: response.expires_in))
                DispatchQueue.main.async {
                    completion(session, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    //MARK: Private

    internal class func profileUsernameRequest(accessToken: String?, completion: @escaping (String?)->()){
        guard let accessToken = accessToken else {
            completion(nil)
            return
        }
        let profileURL = URL(string: ProfileServiceEndpointURL)!
        var urlRequest = URLRequest(url: profileURL)
        let authHeaderValue = "Bearer \(accessToken)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, error == nil {
                let profileResponse = try? JSONDecoder().decode(ProfileEndpointResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(profileResponse?.id)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
        task.resume()
    }

    internal class func authRequest(requestBody: String, clientID: String, clientSecret: String, completion: @escaping (TokenEndpointResponse?, Error?) -> ()){
        guard let authString = "\(clientID):\(clientSecret)".data(using: .ascii)?.base64EncodedString(options: .endLineWithLineFeed) else {
            DispatchQueue.main.async {
                completion(nil, LoginError.ConfigurationMissing)
            }
            return
        }
        let endpoint = URL(string: APITokenEndpointURL)!
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.addValue("application/x-www-form-urlencoded" , forHTTPHeaderField: "content-type")
        urlRequest.httpMethod = "POST"

        let authHeaderValue = "Basic \(authString)"
        urlRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = requestBody.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, let authResponse = try? JSONDecoder().decode(TokenEndpointResponse.self, from: data), error == nil {
                DispatchQueue.main.async {
                    completion(authResponse, error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        })
        task.resume()

    }

}
