//
//  BundleTests.swift
//  JeromeYoutubeTests
//
//  Created by JEROME on 2019/10/9.
//  Copyright © 2019 jerome. All rights reserved.
//

import XCTest

class BundleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_bundleManager_function() {
      let bundle = BundleManager.musicsBundle
      let resourceFileName = "盧廣仲-七天專輯.mp3"
      XCTAssert(bundle.url(forResource: resourceFileName, withExtension: nil) != nil)
    }
}
