// Video+CoredData.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/7.

import CoreData
import Foundation

@objc(Video)
public class Video: NSManagedObject {}

extension Video {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
    return NSFetchRequest<Video>(entityName: "Video")
  }
  
  // 預設值為 0，無法設定為 Int64?
  // 更多：https://aplus.rs/2017/handling-core-data-optional-scalar-attributes/
  @NSManaged public var duration: Int64
  @NSManaged public var id: Int64
  @NSManaged public var name: String?
  @NSManaged public var thumbnailURL: String?
  @NSManaged public var url: String?
  @NSManaged public var youtubeID: String?
  @NSManaged public var categories: NSSet?
  @NSManaged public var savePlace: Int  // 0: 存在本機； 1: 在網上
}

extension Video: HasID {}
extension CoreDataConnect {
  func isTheYoutubeIDExisted(_ id: String) -> Bool {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), id)
    if let result = retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1) {
      return true
    } else {
      return false
    }
  }
  
  public func insertBundleVideos(_ musicsInfo: [String :String], aContext: NSManagedObjectContext? = nil) {
    let localCategoryDictionary = categoryDictionary
    var attributeInfos = [[String: Any]]()
    var id = 1
    for info in musicsInfo {
      let categoryNames = info.value.components(separatedBy: "#")
      var categoryArray = [VideoCategory]()
      for name in categoryNames {
        categoryArray.append(localCategoryDictionary[name]!)
      }
      let categoiesSet = NSSet(array: categoryArray)
      let name = info.key.removeFileExtension()
      let attributeInfo = [
        #keyPath(Video.id): id as Any,
        #keyPath(Video.url): info.key as Any,
        #keyPath(Video.savePlace): 0 as Any,
        #keyPath(Video.name): name as Any,
        #keyPath(Video.categories): categoiesSet,
      ]
      attributeInfos.append(attributeInfo)
      id += 1
    }
    
    do {
      try batchInsert(type: Video.self, attributeInfos: attributeInfos, aContext: aContext)
    } catch {
      logger.log(error.localizedDescription, level: .error)
    }
  }
  
  public func addVideo(by videoID: Int, to categoryNamesString: String, aContext: NSManagedObjectContext? = nil) throws {
    let localCategoryDictionary = categoryDictionary
    let predicate = NSPredicate(format: "%K == %d", #keyPath(Video.id), videoID)
    guard let video = retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1)?.first else {
      throw VideoError.videoIDNotExisted
    }
    do {
      let categoryNames = categoryNamesString.components(separatedBy: "#")
      var categoryArray = [VideoCategory]()
      for name in categoryNames {
        try insertVideoID(in: name, videoID: videoID, aContext: aContext, shouldSaveContext: false)
        categoryArray.append(localCategoryDictionary[name]!)
      }
      var categoiesSet = video.categories
      categoiesSet = categoiesSet?.addingObjects(from: categoryArray) as? NSSet
      let attributeInfo = [
        #keyPath(Video.categories): categoiesSet,
      ]
      try update(type: Video.self, predicate: predicate, limit: 1, attributeInfo: attributeInfo, aContext: aContext, shouldSaveContext: false)
      try persistentContainer.saveContext()
    } catch {
      logger.log(error.localizedDescription, level: .error)
    }
  }
  
  private var categoryDictionary: [String: VideoCategory] { // Key: Name; Value: VideoCategory
    guard let categories = retrieve(type: VideoCategory.self) else {
      fatalError()
    }
    let categoryDictionary = categories.reduce([String: VideoCategory]()) { (dict, category) -> [String: VideoCategory] in
      var dict = dict
      dict[category.name!] = category
      return dict
    }
    return categoryDictionary
  }
}

enum VideoError: Error {
  case videoIDNotExisted
}
