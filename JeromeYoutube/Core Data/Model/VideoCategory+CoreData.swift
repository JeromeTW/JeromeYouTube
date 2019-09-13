//
//  VideoCategory+CoreData.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/12.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData
import Foundation

extension CoreDataConnect {
  public func insertFirstVideoCategoryIfNeeded() {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), VideoCategory.undeineCatogoryName)
    if let categories = retrieve(type: VideoCategory.self, predicate: predicate, sort: nil, limit: 1), categories.isEmpty == false {
      return
    }
    guard insert(type: VideoCategory.self, attributeInfo: [
        #keyPath(VideoCategory.name) : VideoCategory.undeineCatogoryName as Any,
        #keyPath(VideoCategory.id) : generateNewID(VideoCategory.self) as Any,
        #keyPath(VideoCategory.order) : generateNewOrder(VideoCategory.self) as Any
      ]) else {
        fatalError()
    }
  }
}

extension VideoCategory: HasID { }
extension VideoCategory: HasOrder { }
extension VideoCategory {
  static let undeineCatogoryName = "未分類"
}
