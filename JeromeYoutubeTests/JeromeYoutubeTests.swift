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
  
  func testImageLoader() {
    let imageLoader = ImageLoader.shared
    
    let successfulURL = URL(string: "https://i.ytimg.com/vi/z_xrgqTnM5E/hqdefault.jpg?sqp=-oaymwEiCKgBEF5IWvKriqkDFQgBFQAAAAAYASUAAMhCPQCAokN4AQ==&rs=AOn4CLBTL27i7gGtKmOqugtYG1hhdl8k-Q")!
    let exp = expectation(description: "Download the same image twice, but request once")
    var counter = 0
    imageLoader.imageByURL(successfulURL) { (image, url) in
      if image != nil {
        exp.fulfill()
        counter += 1
        // NOTE: 因為有 XCTAssert，所以 exp.fulfill() 不會直接結束此測試，而是要等所有的 XCTAssert 都跑過。這是我的猜測
        XCTAssert(counter < 2)
      }
    }
    imageLoader.imageByURL(successfulURL) { (image, url) in
      
      if image != nil {
        exp.fulfill()
        counter += 1
        XCTAssert(counter < 2)
      }
    }
    waitForExpectations(timeout: 10) { (error) in
      print("Timeout Error: \(error)")
    }
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
