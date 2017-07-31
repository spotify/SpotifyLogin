//
//  SpotifyLoginTests.swift
//  SpotifyLoginTests
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import XCTest
@testable import SpotifyLogin

class SpotifyLoginTests: XCTestCase {

    func testURLParsing(){
        let urlBuilder = URLBuilder(clientID: "id", clientSecret: "secret", redirectURL: URL(string:"spotify.com")!)
        // Parse valid url
        let validURL = URL(string: "scheme://?code=spotify")!
        let parsedValidURL = urlBuilder.parse(url: validURL)
        XCTAssertFalse(parsedValidURL.error)
        XCTAssertEqual(parsedValidURL.code, "spotify")
        // Parse invalid url
        let invalidURL = URL(string: "http://scheme")!
        let parsedInvalidURL = urlBuilder.parse(url: invalidURL)
        XCTAssertTrue(parsedInvalidURL.error)
        XCTAssertNil(parsedInvalidURL.code)
    }

    func testCanHandleURL(){
        let urlBuilder = URLBuilder(clientID: "id", clientSecret: "secret", redirectURL: URL(string:"spotify://")!)
        // Handle valid URL
        let validURL = URL(string: "spotify://")!
        XCTAssertTrue(urlBuilder.canHandleURL(validURL))
        // Handle invalid URL
        let invalidURL = URL(string: "http://spotify.com")!
        XCTAssertFalse(urlBuilder.canHandleURL(invalidURL))
    }

    func testAuthenticationURL(){
        let urlBuilder = URLBuilder(clientID: "id", clientSecret: "secret", redirectURL: URL(string:"spotify://")!)
        let webAuthenticationURL = urlBuilder.authenticationURL(type: .Web, scopes: [])
        XCTAssertNotNil(webAuthenticationURL)
        let appAuthenticationURL = urlBuilder.authenticationURL(type: .App, scopes: [.Streaming])
        XCTAssertNotNil(appAuthenticationURL)
    }

    func testSessionValid(){
        let validSession = Session(userName: "userName", accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: Date(timeIntervalSinceNow: 100))
        XCTAssertTrue(validSession.isValid())
        let inalidSession = Session(userName: "userName", accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: Date(timeIntervalSinceNow: -100))
        XCTAssertFalse(inalidSession.isValid())
    }

    func testUsername(){
        let testUsername = "fakeUser"
        let session = Session(userName: testUsername, accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: Date())
        SpotifyLogin.shared.session = session
        XCTAssertEqual(SpotifyLogin.shared.userName, testUsername)
    }

    func testGetToken(){
        let emptySessionExpectation = expectation(description: "token expectation")
        SpotifyLogin.shared.session = nil
        SpotifyLogin.shared.getAccessToken { (token, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(token)
            emptySessionExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)

        let unconfiguredSessionExpectation = expectation(description: "token expectation")
        let testToken = "fakeToken"
        let tokenSession = Session(userName: "testUsername", accessToken: testToken, refreshToken: "refreshToken", expirationDate: Date.distantFuture)
        SpotifyLogin.shared.session = tokenSession
        SpotifyLogin.shared.getAccessToken { (token, error) in
            XCTAssertNotNil(error)
            unconfiguredSessionExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)

        let validSessionExpectation = expectation(description: "configuration expectation")
        SpotifyLogin.shared.configure(clientID: "clientID", clientSecret: "clientSecret", redirectURL: URL(string:"spotify.com")!)
        SpotifyLogin.shared.getAccessToken { (token, error) in
            XCTAssertNil(error)
            XCTAssertEqual(token, testToken)
            validSessionExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.5, handler: nil)
    }

    func testLogout(){
        let testSession = Session(userName: "testUsername", accessToken: "testToken", refreshToken: "refreshToken", expirationDate: Date.distantFuture)
        SpotifyLogin.shared.session = testSession
        SpotifyLogin.shared.logout()
        XCTAssertNil(SpotifyLogin.shared.session)
    }

}
