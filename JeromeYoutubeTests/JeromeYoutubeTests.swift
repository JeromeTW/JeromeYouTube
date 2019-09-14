//
//  JeromeYoutubeTests.swift
//  JeromeYoutubeTests
//
//  Created by JEROME on 2019/9/14.
//  Copyright © 2019 jerome. All rights reserved.
//

import XCTest
import JeromeYoutube

class JeromeYoutubeTests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testYoutubeHelper() {
    let successStrings: [String] = ["6v2L2UGZJAM", "https://www.youtube.com/watch?v=XULUBg_ZcAU"]
    
    for string in successStrings {
      if let _ = try? YoutubeHelper.grabYoutubeIDBy(text: string).get() {
      } else {
        XCTAssert(false)
      }
    }
    
    for string in successStrings {
      if let _ = try? YoutubeHelper.grabYoutubeIDBy(text: string).get() {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
    }
    
    let failedStrings: [String] = [
      "https://www.google.com/search?q=asd&oq=asd&aqs=chrome..69i57j0l5.255j0j8&sourceid=chrome&ie=UTF-8", "https://www.youtube.com/results?search_query=music",
      "6v2L2UGZJAM2",
      "6v2L2UGZJ"
    ]
    
    for string in failedStrings {
      if let _ = try? YoutubeHelper.grabYoutubeIDBy(text: string).get() {
        XCTAssert(false)
      }
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
