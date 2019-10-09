// YoutubeHelper.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/7.

import CoreData
import Foundation

struct YoutubeHelper {
  static func grabYoutubeIDBy(text: String) -> Result<String, Error> {
    let youtubeIDCount = 11
    if text.count == youtubeIDCount {
      return .success(text)
    }
    let youtubeDomain = "youtube.com"
    let parameterSeparator = "?v="
    guard text.contains(youtubeDomain), text.contains(parameterSeparator), text.components(separatedBy: parameterSeparator).count == 2 else {
      return .failure(YoutubeHelperError.youtubeIDInvalid)
    }
    return .success(text.components(separatedBy: parameterSeparator)[1])
  }

  static func add(_ youtubeID: String, to category: VideoCategory, in coreDataConnect: CoreDataConnect, aContext: NSManagedObjectContext? = nil) throws {
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
    if let videos = coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1, aContext: aContext), let video = videos.first {
      // DB 中已經有該影片
      guard let categories = video.categories else {
        fatalError()
      }
      if categories.contains(category as Any) {
        // 之前已經加入了此分類
        throw YoutubeHelperError.duplicateVideoInTheSameCategory
      } else {
        var newCategoriesArray = categories.allObjects
        newCategoriesArray.append(category as Any)
        let newCategories = NSSet(array: newCategoriesArray)
        try coreDataConnect.update(type: Video.self, predicate: predicate, attributeInfo: [
          #keyPath(Video.categories): newCategories,
        ], aContext: aContext)
      }
    } else {
      // DB 中沒有該影片
      let categories = NSSet(array: [category as Any])
      try coreDataConnect.insert(type: Video.self, attributeInfo: [
        #keyPath(Video.id): coreDataConnect.generateNewID(Video.self) as Any,
        #keyPath(Video.order): coreDataConnect.generateNewOrder(Video.self) as Any,
        #keyPath(Video.youtubeID): youtubeID as Any,
        #keyPath(Video.savePlace): 1 as Any,
        #keyPath(Video.categories): categories,
      ], aContext: aContext)
      guard let video = coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1, aContext: aContext)?.first else {
        return
      }
      YoutubePlayer.shared.getAndSaveVideoInfomation(video)
    }
  }
}

enum YoutubeHelperError: Error {
  case youtubeIDInvalid
  case duplicateVideoInTheSameCategory
}
