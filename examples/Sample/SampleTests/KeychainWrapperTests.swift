//
//  KeychainWrapperTests.swift
//  SampleTests
//
//  Created by Nataliya  on 10/10/17.
//  Copyright © 2017 Spotify. All rights reserved.
//

import XCTest
@testable import SpotifyLogin

class KeychainWrapperTests: XCTestCase {
    
    let testKey = "key"
    let testData = "test".data(using: .utf8)!
    
    override func tearDown() {
        _ = KeychainWrapper.removeData(forKey:testKey)
    }
    
    func testThatRemovingDataBeforeSavingItFails() {
        XCTAssertFalse(KeychainWrapper.removeData(forKey:testKey))
    }
    
    func testThatRetrievingDataBeforeSavingItReturnsNil() {
        XCTAssertNil(KeychainWrapper.data(forKey: testKey))
    }
    
    func testThatRemovingDataAfterSavingItSucceeds() {
        XCTAssertTrue(KeychainWrapper.save(testData, forKey:testKey))
        XCTAssertTrue(KeychainWrapper.removeData(forKey:testKey))
    }
    
    func testThatRetrievingDataAfterSavingItReturnsTheData() {
        XCTAssertTrue(KeychainWrapper.save(testData, forKey:testKey))
        XCTAssertNotNil(KeychainWrapper.data(forKey: testKey))
    }
    
}
