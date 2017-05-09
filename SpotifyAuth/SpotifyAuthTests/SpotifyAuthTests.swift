//
//  SpotifyAuthTests.swift
//  SpotifyAuthTests
//
//  Created by Roy Marmelstein on 2017-05-09.
//  Copyright © 2017 Spotify. All rights reserved.
//

import XCTest
@testable import SpotifyAuth

class SpotifyAuthTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expectatioin = expectation(description: "something happening")
        var url = URL(string: "labcaviar://#access_token=BQD0cOblsjhTMxXnvanbHhlFsEzs0qj1Spou7MqgO4-FQjcKf4jvQneJzlMHYzYHENdrgeYO82rgQPaoO8eydSFyursIZ_PSR38Sl-6HEzipQWSjgqzWqx6o1rCamFXPK7-mWbBW1GCSrLxQ-Blv2qbxFVm-z6ePg5tGxmRcnXNWLRzKGkF9svdUol_RdBD70Q&token_type=Bearer&expires_in=3600")

        let auth = Auth()
        auth.handleAuthCallback(url: url!) { (error, session) in
            print("error \(error), session \(error)")
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
