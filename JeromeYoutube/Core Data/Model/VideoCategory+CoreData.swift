// VideoCategory+CoreData.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/7.

import CoreData
import Foundation

@objc(VideoCategory)
public class VideoCategory: NSManagedObject {}

extension VideoCategory {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCategory> {
    return NSFetchRequest<VideoCategory>(entityName: "VideoCategory")
  }

  @NSManaged public var id: Int64
  @NSManaged public var name: String?
  @NSManaged public var order: Int64
  @NSManaged public var videos: NSOrderedSet?
  @NSManaged public var videoIDOrders: [Int]?
}

// MARK: Generated accessors for videos

extension VideoCategory {
  @objc(insertObject:inVideosAtIndex:)
  @NSManaged public func insertIntoVideos(_ value: Video, at idx: Int)

  @objc(removeObjectFromVideosAtIndex:)
  @NSManaged public func removeFromVideos(at idx: Int)

  @objc(insertVideos:atIndexes:)
  @NSManaged public func insertIntoVideos(_ values: [Video], at indexes: NSIndexSet)

  @objc(removeVideosAtIndexes:)
  @NSManaged public func removeFromVideos(at indexes: NSIndexSet)

  @objc(replaceObjectInVideosAtIndex:withObject:)
  @NSManaged public func replaceVideos(at idx: Int, with value: Video)

  @objc(replaceVideosAtIndexes:withVideos:)
  @NSManaged public func replaceVideos(at indexes: NSIndexSet, with values: [Video])

  @objc(addVideosObject:)
  @NSManaged public func addToVideos(_ value: Video)

  @objc(removeVideosObject:)
  @NSManaged public func removeFromVideos(_ value: Video)

  @objc(addVideos:)
  @NSManaged public func addToVideos(_ values: NSOrderedSet)

  @objc(removeVideos:)
  @NSManaged public func removeFromVideos(_ values: NSOrderedSet)
}

extension CoreDataConnect {
  public func insertBundleCategories(_ categoryNames: [String], aContext: NSManagedObjectContext? = nil) {
    var attributeInfos = [[String: Any]]()
    var id = 1
    var order = 1
    for name in categoryNames {
      let attributeInfo = [
        #keyPath(VideoCategory.name): name as Any,
        #keyPath(VideoCategory.id): id as Any,
        #keyPath(VideoCategory.order): order as Any,
      ]
      attributeInfos.append(attributeInfo)
      id += 1
      order += 1
    }
    do {
      try batchInsert(type: VideoCategory.self, attributeInfos: attributeInfos, aContext: aContext)
    } catch {
      logger.log(error.localizedDescription, level: .error)
    }
  }

  public func insertCategory(_ name: String, aContext: NSManagedObjectContext? = nil) throws {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), name)
    if let categories = retrieve(type: VideoCategory.self, predicate: predicate, sort: nil, limit: 1, aContext: aContext) {
      throw VideoCategoryError.duplicateCategoryName
    }
    do {
      try insert(type: VideoCategory.self, attributeInfo: [
        #keyPath(VideoCategory.name): name as Any,
        #keyPath(VideoCategory.id): generateNewID(VideoCategory.self) as Any,
        #keyPath(VideoCategory.order): generateNewOrder(VideoCategory.self) as Any,
      ], aContext: aContext)
    } catch {
      fatalError()
    }
  }
  
  // MARK: - Videos Order
  public func setCategoryVideoOrders(_ name: String, videoOrders: [Int], aContext: NSManagedObjectContext? = nil) {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), name)

    do {
      try update(type: VideoCategory.self, predicate: predicate, limit: 1, attributeInfo: [
        #keyPath(VideoCategory.videoIDOrders): videoOrders as Any,
      ], aContext: aContext)
    } catch {
      fatalError()
    }
  }
  
  public func insertVideoID(in cateogoryName: String, videoID: Int, aContext: NSManagedObjectContext? = nil, shouldSaveContext: Bool = true) throws {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), cateogoryName)
    guard let categories = retrieve(type: VideoCategory.self, predicate: predicate, sort: nil, limit: 1, aContext: aContext), let category = categories.first else {
      throw VideoCategoryError.categoryNameNotExisted
    }

    var orders = category.videoIDOrders ?? []
    guard orders.contains(videoID) == false else {
      // 已經有在 Category 中了，不用再插入了
      return
    }
    
    orders.insert(videoID, at: 0)
    
    do {
      try update(type: VideoCategory.self, predicate: predicate, limit: 1, attributeInfo: [
        #keyPath(VideoCategory.videoIDOrders): orders as Any,
      ], aContext: aContext, shouldSaveContext: shouldSaveContext)
    } catch {
      fatalError()
    }
  }
  
  public func delete(_ videoID: Int, cateogoryName: String, aContext: NSManagedObjectContext? = nil) throws {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), cateogoryName)
    guard let categories = retrieve(type: VideoCategory.self, predicate: predicate, sort: nil, limit: 1, aContext: aContext), let category = categories.first else {
      throw VideoCategoryError.categoryNameNotExisted
    }
    var orders = category.videoIDOrders ?? []
    guard let index = orders.firstIndex(of: videoID) else {
      // Video 不存在此 Category 中了
      return
    }
    orders.remove(at: index)
    do {
      try update(type: VideoCategory.self, predicate: predicate, limit: 1, attributeInfo: [
        #keyPath(VideoCategory.videoIDOrders): orders as Any,
      ], aContext: aContext)
    } catch {
      fatalError()
    }
    let videoPredicate = NSPredicate(format: "%K == %d", #keyPath(Video.id), videoID)
    do {
      try delete(type: Video.self, predicate: videoPredicate)
    } catch {
      fatalError()
    }
  }
}

enum VideoCategoryError: Error {
  case duplicateCategoryName
  case categoryNameNotExisted
}

extension VideoCategory: HasID {}
extension VideoCategory: HasOrder {} // 數字越大在越前面，最小是 1 在最後面。
extension VideoCategory {
  static let undeineCatogoryName = "未分類"
}
