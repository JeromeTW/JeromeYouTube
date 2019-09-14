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
    do {
      try insert(type: VideoCategory.self, attributeInfo: [
        #keyPath(VideoCategory.name) : VideoCategory.undeineCatogoryName as Any,
        #keyPath(VideoCategory.id) : generateNewID(VideoCategory.self) as Any,
        #keyPath(VideoCategory.order) : generateNewOrder(VideoCategory.self) as Any
        ])
    } catch {
      fatalError()
    }
  }
}

extension VideoCategory: HasID { }
extension VideoCategory: HasOrder { } // 數字越大在越前面，最小是 1 在最後面。
extension VideoCategory {
  static let undeineCatogoryName = "未分類"
}
