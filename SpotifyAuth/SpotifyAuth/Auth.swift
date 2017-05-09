//
//  Auth.swift
//  SpotifyAuth
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import Foundation

enum AuthScope: String {
    case Streaming
    enum Playlist: String {
        case ReadPrivate
        case ReadCollaborative
        case ModifyPublic
        case ModifyPrivate
    }
    enum User: String {
        case FollowRead
        case LibraryRead
        case LibraryModify
        case ReadPrivate
        case ReadTop
        case ReadBirthDate
        case ReadEmail
    }
}

enum AuthError: Error {
    case General
}

public class Auth {

    public typealias AuthCallback = (Error?, Session?) -> ()

    var clientID: String?
    var redirectURL: URL?
    var requestedScopes: [String]?
    var session: Session?
    var tokenSwapURL: URL?
    var tokenRefreshURL: URL?

    public class func loginURL(clientID: String?, redirectURL: URL?, scopes: [String]?, responseType: String = "code", campaignID: String = Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: String = Constants.AuthServiceEndpointURL.rawValue) -> URL? {
        guard let clientID = clientID, let redirectURL = redirectURL, let scopes = scopes else {
            return nil
        }

        var params = [String: String]()
        params["client_id"] = clientID
        params["redirect_uri"] = redirectURL.absoluteString
        params["response_type"] = responseType
        params["show_dialog"] = "true"


        if (scopes.count > 0) {
            params["scope"] = scopes.joined(separator: " ")
        }

        params["nosignup"] = "true"
        params["nolinks"] = "true"

        params[Constants.AuthUTMSourceQueryKey.rawValue] = Constants.AuthUTMSourceQueryValue.rawValue
        params[Constants.AuthUTMMediumQueryKey.rawValue] = Constants.AuthUTMMediumCampaignQueryValue.rawValue
        params[Constants.AuthUTMCampaignQueryKey.rawValue] = campaignID

        let pairs = params.map{"\($0)=\($1)"}
        let loginPageURLString = "\(endpoint)authorize?\(pairs.joined(separator: "&"))"
        let escapedString = loginPageURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ??  String()

        return URL(string: escapedString)
    }

    private func parse(url: URL) -> (authToken: String?, expiresIn: Int?, error: Bool) {
        var authToken: String?
        var expiresIn: Int?
        var error = false
        if let fragment = url.fragment {
            let fragmentItems = fragment.components(separatedBy: "&").reduce([String:String]()) { (dict, fragmentItem) in
                var mutableDict = dict
                let splitValue = fragmentItem.components(separatedBy: "=")
                mutableDict[splitValue[0]] = splitValue[1]
                return mutableDict
            }
            authToken = fragmentItems["access_token"]
            if let expiresInString = fragmentItems["expires_in"] {
                expiresIn = Int(expiresInString)
            }
            error = fragment.contains("error")
        }
        return (authToken: authToken, expiresIn: expiresIn, error: error)
    }

    public func handleAuthCallback(url: URL, callback: @escaping AuthCallback) {
        let parsedURL = parse(url: url)
        if parsedURL.error  {
            callback(AuthError.General, nil)
            return
        }

        if let accessToken = parsedURL.authToken, let expiresIn = parsedURL.expiresIn {
            let profileURL = URL(string: Constants.ProfileServiceEndpointURL.rawValue)!
            var profileRequest = URLRequest(url: profileURL)
            let authHeaderValue = "Bearer \(accessToken)"
            profileRequest.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: profileRequest, completionHandler: { (data, response, error) in
                if (error != nil) {
                    callback(error, nil)
                    return
                }
                if let data = data {
                    var jsonObject: [String: Any]?
                    do {
                        jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    }
                    catch let error {
                        callback(error, nil)
                    }
                    if let jsonObject = jsonObject, let userID = jsonObject["id"] as? String {
                        let session = Session(userName: userID, accessToken: accessToken, encryptedRefreshToken: nil, expirationDate: Date(timeIntervalSinceNow: Double(expiresIn)))
                        callback(nil, session)
                    }
                }
            })
            task.resume()

        }
//            } else if (dict[@"code"]) {
//
//                NSDictionary *params = @{ @"code" : dict[@"code"] };
//
//                NSMutableArray *pairs = [NSMutableArray array];
//                for (NSString *key in params) {
//                    NSString *formattedString = [NSString stringWithFormat:@"%@=%@",
//                        [SPTAuth urlEncodeString:key],
//                        [SPTAuth urlEncodeString:params[key]]
//                    ];
//                    [pairs addObject:formattedString];
//                }
//
//                NSString *requestString = [pairs componentsJoinedByString:@"&"];
//                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.tokenSwapURL];
//                request.HTTPMethod = @"POST";
//                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//                request.HTTPBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
//
//                NSURLResponse *response = nil;
//                NSError *err = nil;
//                NSData *returnData = [NSURLConnection sendSynchronousRequest:request
//                    returningResponse:&response
//                    error:&err];
//
//                if (err != nil) {
//                    if (block) {
//                        dispatch_async(dispatch_get_main_queue(), ^{ block(err, nil); });
//                    }
//                    return;
//                }
//
//                id json = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:&err];
//
//                if (err != nil) {
//                    if (block) {
//                        dispatch_async(dispatch_get_main_queue(), ^{ block(err, nil); });
//                    }
//                    return;
//                }
//
//                NSUInteger statusCode = 200;
//
//                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                    statusCode = httpResponse.statusCode;
//                }
//
//                if (json[SPTAuthJSONErrorKey] != nil || statusCode != 200) {
//                    NSString *errorDescription = json[SPTAuthJSONErrorDescriptionKey] ?: json[SPTAuthJSONErrorKey];
//                    NSError *error = [NSError errorWithDomain:SPTAuthErrorDomain
//                    code:statusCode
//                    userInfo:@{ NSLocalizedDescriptionKey : errorDescription}];
//                    if (block) {
//                        dispatch_async(dispatch_get_main_queue(), ^{ block(error, nil); });
//                    }
//                    return;
//                }
//
//                NSString *accessToken = json[@"access_token"];
//                NSTimeInterval expirationTime = [json[@"expires_in"] doubleValue];
//                NSString *encryptedRefreshToken = json[@"refresh_token"];
//
//                // Fetch username from another endpoint...
//                NSURL *profileURL = [NSURL URLWithString:SPTProfileServiceEndpointURL];
//                NSMutableURLRequest *profileRequest = [NSMutableURLRequest requestWithURL:profileURL];
//                NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
//                [profileRequest setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
//
//                NSURLResponse *profileResponse = nil;
//                NSError *profileError = nil;
//                NSData *profileReturnData = [NSURLConnection sendSynchronousRequest:profileRequest
//                returningResponse:&profileResponse
//                error:&profileError];
//
//                if (profileError) {
//                    if (block) {
//                        dispatch_async(dispatch_get_main_queue(), ^{ block(profileError, nil); });
//                    }
//                    return;
//                }
//
//                id profileJSON = [NSJSONSerialization JSONObjectWithData:profileReturnData options:0 error:&profileError];
//
//                if (profileError) {
//                    if (block) {
//                        dispatch_async(dispatch_get_main_queue(), ^{ block(profileError, nil); });
//                    }
//                    return;
//                }
//
//                NSString *userName = profileJSON[@"id"];
//
//                if (block) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:expirationTime];
//                        self.session = [[SPTSession alloc] initWithUserName:userName
//                            accessToken:accessToken
//                            encryptedRefreshToken:encryptedRefreshToken
//                            expirationDate:expirationDate];
//                        block(nil, self.session);
//                        });
//                }
//            } else {
//                NSString *errorDescription = dict[SPTAuthJSONErrorDescriptionKey] ?: dict[SPTAuthJSONErrorKey];
//                NSError *error = [NSError errorWithDomain:SPTAuthErrorDomain
//                code:0
//                userInfo:@{ NSLocalizedDescriptionKey : errorDescription}];
//                if (block) {
//                    dispatch_async(dispatch_get_main_queue(), ^{ block(error, nil); });
//                }
//            }
//            });
    }

    public class func supportsApplicationAuthentication() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: Constants.AppAuthURL.rawValue)!)
    }

    public class func spotifyApplicationIsInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "spotify:")!)
    }

    public func webAuthenticationURL() -> URL? {
        return authenticationURL(endpoint: Constants.AuthServiceEndpointURL.rawValue)
    }

    public func appAuthenticationURL() -> URL? {
        return authenticationURL(endpoint: Constants.AppAuthURL.rawValue)
    }

    public func canHandleURL(callbackURL: URL) -> Bool {
        guard let redirectURLString = redirectURL?.absoluteString else {
            return false
        }

        return callbackURL.absoluteString.hasPrefix(redirectURLString)
    }


    private func authenticationURL(endpoint: String) -> URL? {
        let responseType = (tokenSwapURL != nil) ? "code" : "token"
        return Auth.loginURL(clientID: self.clientID, redirectURL: self.redirectURL, scopes: self.requestedScopes, responseType: responseType, campaignID: Constants.AuthUTMMediumCampaignQueryValue.rawValue, endpoint: endpoint)
    }

}
