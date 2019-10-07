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

  func test_CoreDataConnect_insertFirstVideoCategoryIfNeeded() {
    coreDataConnect.insertFirstVideoCategoryIfNeeded()
    guard let categories = coreDataConnect.retrieve(type: VideoCategory.self) else {
      XCTFail()
      return
    }

    XCTAssert(categories.count == 1)
  }

  func test_insert_five_categories() {
    do {
      try coreDataConnect.insertCategory("1")
      try coreDataConnect.insertCategory("2")
      try coreDataConnect.insertCategory("3")
      try coreDataConnect.insertCategory("4")
      try coreDataConnect.insertCategory("5")
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self) else {
        XCTFail()
        return
      }
      XCTAssert(categories.count == 5)
      let count = coreDataConnect.getCount(type: VideoCategory.self, predicate: nil)
      XCTAssert(count == 5)
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail()
    }
  }

  func test_insert_duplicate_categories() {
    do {
      try coreDataConnect.insertCategory("1")
      try coreDataConnect.insertCategory("1")
      XCTFail("Cannot insert duplicate categories.")
    } catch VideoCategoryError.duplicateCategoryName {
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
    }
  }

  func test_insert_three_videos() {
    do {
      try coreDataConnect.insertCategory("1")
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self), let category = categories.first else {
        XCTFail()
        return
      }
      try YoutubeHelper.add("id1", to: category, in: coreDataConnect)
      try YoutubeHelper.add("id2", to: category, in: coreDataConnect)
      try YoutubeHelper.add("id3", to: category, in: coreDataConnect)
      let count = coreDataConnect.getCount(type: Video.self, predicate: nil)
      XCTAssert(count == 3)
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail()
    }
  }

  func test_insert_duplicate_videos_in_same_category() {
    do {
      try coreDataConnect.insertCategory("1")
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self), let category = categories.first else {
        XCTFail()
        return
      }
      try YoutubeHelper.add("id1", to: category, in: coreDataConnect)
      try YoutubeHelper.add("id1", to: category, in: coreDataConnect)
      XCTFail("Cannot insert duplicate videos in the same category.")
    } catch YoutubeHelperError.duplicateVideoInTheSameCategory {
      // Pass Test
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail()
    }
  }

  func test_insert_duplicate_videos_in_different_category() {
    do {
      try coreDataConnect.insertCategory("1")
      try coreDataConnect.insertCategory("2")
      guard let categories = coreDataConnect.retrieve(type: VideoCategory.self) else {
        XCTFail()
        return
      }
      let category1 = categories[0]
      let category2 = categories[1]
      let youtubeID = "id1"
      try YoutubeHelper.add(youtubeID, to: category1, in: coreDataConnect)
      try YoutubeHelper.add(youtubeID, to: category2, in: coreDataConnect)
      let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
      guard let videos = coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1), let video = videos.first else {
        XCTFail()
        return
      }
      XCTAssert(video.categories?.count == 2)
      // Pass Test
    } catch YoutubeHelperError.duplicateVideoInTheSameCategory {
      XCTFail("User Can insert duplicate videos in the different category.")
    } catch {
      logger.log("Error: \(error.localizedDescription)", level: .error)
      XCTFail()
    }
  }
}
