// CoreDataTests.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/7.

import CoreData
import XCTest

class CoreDataTests: XCTestCase {
  lazy var coreDataConnect = CoreDataConnect(container: mockPersistantContainer)

  // MARK: mock in-memory persistant store

  lazy var managedObjectModel: NSManagedObjectModel = {
    // TestTarget Bundle(for: type(of: self)) 不同於w Bundle.main
    // Bundle.main NSBundle </private/var/containers/Bundle/Application/26BCCCA6-B521-4FF0-8EB7-52F7A955630E/JeromeYoutube.app> (loaded)
    // po Bundle(for: type(of: self)) NSBundle </var/containers/Bundle/Application/26BCCCA6-B521-4FF0-8EB7-52F7A955630E/JeromeYoutube.app/PlugIns/JeromeYoutubeTests.xctest> (loaded)
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])!
    return managedObjectModel
  }()

  lazy var mockPersistantContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Video", managedObjectModel: self.managedObjectModel)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false // Make it simpler in test env

    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { description, error in
      // Check if the data store is in memory
      precondition(description.type == NSInMemoryStoreType)

      // Check if creating container wrong
      if let error = error {
        fatalError("Create an in-mem coordinator failed \(error)")
      }
    }
    return container
  }()

  var context: NSManagedObjectContext {
    return coreDataConnect.viewContext
//    return coreDataConnect.backgroundContext
  }
  
  override class func setUp() {
    XCTestCase.setUp()
    // This is the setUp() class method.
    // It is called before the first test method begins.
    // Set up any overall initial state here.
    // 如果 logger.configure 寫在 TestsAppDelegate 中，在這裡會沒有反應，可能是因為在不同的 Target 下。
    logger.configure([.fault, .error, .debug, .info, .defaultLevel], shouldShow: false, shouldCache: false)
  }

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
    flushData()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func flushData() {
    do {
      try coreDataConnect.delete(type: VideoCategory.self, predicate: nil)
      try coreDataConnect.delete(type: Video.self, predicate: nil)
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
    }
  }

  func test_insert_five_categories() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      try coreDataConnect.insertCategory("2", aContext: context)
      try coreDataConnect.insertCategory("3", aContext: context)
      try coreDataConnect.insertCategory("4", aContext: context)
      try coreDataConnect.insertCategory("5", aContext: context)
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context) else {
        XCTFail("")
        return
      }
      XCTAssert(categories.count == 5)
      let count = coreDataConnect.getCount(type: VideoCategory.self, predicate: nil, aContext: context)
      XCTAssert(count == 5)
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }

  func test_insert_duplicate_categories() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      try coreDataConnect.insertCategory("1", aContext: context)
      XCTFail("Cannot insert duplicate categories.")
    } catch VideoCategoryError.duplicateCategoryName {
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
    }
  }

  func test_insert_three_videos() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context), let category = categories.first else {
        XCTFail("")
        return
      }
      try YoutubeHelper.add("id1", to: [category], in: coreDataConnect, aContext: context)
      try YoutubeHelper.add("id2", to: [category], in: coreDataConnect, aContext: context)
      try YoutubeHelper.add("id3", to: [category], in: coreDataConnect, aContext: context)
      let count = coreDataConnect.getCount(type: Video.self, predicate: nil, aContext: context)
      XCTAssert(count == 3)
      XCTAssert(category.videoIDOrders == [3,2,1])
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }

  func test_insert_duplicate_videos_in_same_category() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context), let category = categories.first else {
        XCTFail("")
        return
      }
      try YoutubeHelper.add("id1", to: [category], in: coreDataConnect, aContext: context)
      try YoutubeHelper.add("id1", to: [category], in: coreDataConnect, aContext: context)
      XCTAssert(category.videos?.count == 1)
      XCTAssert(category.videoIDOrders == [1])
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }

  func test_insert_duplicate_videos_in_different_category() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      try coreDataConnect.insertCategory("2", aContext: context)
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context) else {
        XCTFail("")
        return
      }
      let category1 = categories[0]
      let category2 = categories[1]
      let youtubeID = "id1"
      try YoutubeHelper.add(youtubeID, to: [category1], in: coreDataConnect, aContext: context)
      try YoutubeHelper.add(youtubeID, to: [category2], in: coreDataConnect, aContext: context)
      let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
      guard let videos = coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1, aContext: context), let video = videos.first else {
        XCTFail("")
        return
      }
      XCTAssert(video.categories?.count == 2)
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }
  
  func test_insert_a_video_in_category_then_remove_category() {
    // the video should be gone.
    do {
      let categoryName = try createACategoryAndInsertAYoutubeVideo()
      let categoryPredicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), categoryName)
      try coreDataConnect.delete(type: VideoCategory.self, predicate: categoryPredicate, aContext: context)
      let categoryCount = coreDataConnect.getCount(type: VideoCategory.self, predicate: nil, aContext: context)
      let videoCount = coreDataConnect.getCount(type: Video.self, predicate: nil, aContext: context)
      XCTAssert(categoryCount == 0)
      XCTAssert(videoCount == 0)
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }
  
  func test_insert_a_video_in_category_then_remove_video() {
    // the video should be gone.
    do {
      let categoryName = try createACategoryAndInsertAYoutubeVideo()
      try coreDataConnect.delete(1, cateogoryName: categoryName, aContext: context)
      let categoryCount = coreDataConnect.getCount(type: VideoCategory.self, predicate: nil, aContext: context)
      let videoCount = coreDataConnect.getCount(type: Video.self, predicate: nil, aContext: context)
      XCTAssert(categoryCount == 1)
      XCTAssert(videoCount == 0)
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }
  
  func test_insertBundleCategories_insertBundleVideos() {
    let bundle = Bundle(for: type(of: self))
    let jsonURL = bundle.url(forResource: "importTest.json", withExtension: nil)!
    // get json data
    let result = BundleManager.parseJson(aJsonURL: jsonURL)
    let categoryNames = result.categories
    let musicsInfo = result.musicsInfo
    
    // add categories
    coreDataConnect.insertBundleCategories(categoryNames, aContext: context)
    
    // add videos
    coreDataConnect.insertBundleVideos(musicsInfo, aContext: context)
    
    guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context) else {
      XCTFail("")
      return
    }
    let category1 = categories[0] // 跑步
    XCTAssert(category1.name == "跑步")
    XCTAssert(category1.videos?.count == 2)
    let category2 = categories[1] // 未分類
    XCTAssert(category2.name == "未分類")
    XCTAssert(category2.videos?.count == 1)
  }
  
  func test_copy_a_video_to_another_category() {
    do {
      try coreDataConnect.insertCategory("1", aContext: context)
      try coreDataConnect.insertCategory("2", aContext: context)
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context) else {
        XCTFail("")
        return
      }
      let category1 = categories[0]
      let category2 = categories[1]
      let youtubeID = "id1"
      try YoutubeHelper.add(youtubeID, to: [category1], in: coreDataConnect, aContext: context)
      let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
      guard let videos = coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1, aContext: context), let video = videos.first else {
        XCTFail("")
        return
      }
      let videoID = Int(exactly: video.id)!
      try coreDataConnect.addVideo(by: videoID, to: category2.name!, aContext: context)
      XCTAssert(category1.videos?.count == 1)
      XCTAssert(category2.videos?.count == 1)
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail("")
    }
  }
  
  private func createACategoryAndInsertAYoutubeVideo() throws -> String {
    let categoryName = "1"
    try coreDataConnect.insertCategory(categoryName, aContext: context)
    guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, aContext: context), let category = categories.first else {
      XCTFail("")
      fatalError()
    }
    let youtubeID = "id1"
    try YoutubeHelper.add(youtubeID, to: [category], in: coreDataConnect, aContext: context)
    return categoryName
  }
}
