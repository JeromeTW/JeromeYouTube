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
  @NSManaged public var order: Int64  // TODO: order 要移除放在 Video Category裡。 Video Category加一個欄位叫 orderIDs ? 可能的作法
  @NSManaged public var thumbnailURL: String?
  @NSManaged public var url: String?
  @NSManaged public var youtubeID: String?
  @NSManaged public var categories: NSSet?
  @NSManaged public var savePlace: Int  // 0: 存在本機； 1: 在網上
}

extension Video: HasID {}
extension Video: HasOrder {} // 數字越大在越前面，最小是 1 在最後面。
extension CoreDataConnect {
  func isTheYoutubeIDExisted(_ id: String) -> Bool {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), id)
    if let result = retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1) {
      return true
    } else {
      return false
    }
  }
}
