// JeromeYoutubeTests.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import JeromeYoutube
import XCTest

class JeromeYoutubeTests: XCTestCase {
  
  override class func setUp() {
    XCTestCase.setUp()
    // This is the setUp() class method.
    // It is called before the first test method begins.
    // Set up any overall initial state here.
    // 如果 logger.configure 寫在 TestsAppDelegate 中，在這裡會沒有反應，可能是因為在不同的 Target 下。
    logger.configure([ .fault, .error, .debug, .info, .defaultLevel], shouldShow: false, shouldCache: false)
  }

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
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
      "6v2L2UGZJ",
    ]

    for string in failedStrings {
      if let _ = try? YoutubeHelper.grabYoutubeIDBy(text: string).get() {
        XCTAssert(false)
      }
    }
  }

  class SypQueue: OperationQueue {
    var networkOperationFiredCounter = 0
    override func addOperation(_ op: Operation) {
      if op is NetworkRequestOperation {
        networkOperationFiredCounter += 1
      }
      super.addOperation(op)
    }
  }

  func test_ImageLoader_imageByURL_when_URLExistBefore_doesNotAskQueueShootTwice() { // SypQueue
    let exp = expectation(description: "Download the same image twice, but request once")
    let spyQueue = SypQueue()
    let imageLoader = ImageLoader.shared

    let successfulURL = URL(string: "https://i.ytimg.com/vi/z_xrgqTnM5E/hqdefault.jpg?sqp=-oaymwEiCKgBEF5IWvKriqkDFQgBFQAAAAAYASUAAMhCPQCAokN4AQ==&rs=AOn4CLBTL27i7gGtKmOqugtYG1hhdl8k-Q")!
    imageLoader.queue = spyQueue
    // 一次只運行一個 operation，可以控制 operation 完成的順序，所以只在第二個請求完成後下 fulfill
    imageLoader.queue.maxConcurrentOperationCount = 1
    imageLoader.imageByURL(successfulURL) { image, _ in
      if image != nil {
        logger.log("testImageLoader-1", theOSLog: .test)
      }
    }
    imageLoader.imageByURL(successfulURL) { image, _ in
      if image != nil {
        logger.log("testImageLoader-2", theOSLog: .test)
        XCTAssert(spyQueue.networkOperationFiredCounter < 2)
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 5)
  }

  func test_ImageLoader_imageByURL_with_wrongURL() {
    let exp = expectation(description: "Wrong URL")
    let imageLoader = ImageLoader.shared

    let wrongURL = URL(string: "https://asdasdasdada")!

    imageLoader.imageByURL(wrongURL) { image, _ in
      XCTAssert(image == nil)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 5)
  }
}
