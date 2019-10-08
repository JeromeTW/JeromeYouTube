//
//  BundleManager.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/8.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation
import CoreData

class BundleManager {
  static var shared = BundleManager()
  private init() {}
    
  static var musicsBundle: Bundle = {
    let url = Bundle.main.url(forResource: "Musics", withExtension: "bundle")!
    return Bundle(url: url)!
  }()
  
  static func addMusicsToDBIfNeeded() {
    guard let urls = musicsBundle.urls(forResourcesWithExtension: "mp3", subdirectory: nil) else {
      fatalError()
    }
    
    let undeineCatogorypredicate = NSPredicate(format: "%K == %@", #keyPath(VideoCategory.name), VideoCategory.undeineCatogoryName)
    let coreDataConnect = CoreDataConnect()
    guard let categories = coreDataConnect.retrieve(type: VideoCategory.self, predicate: undeineCatogorypredicate, sort: nil, limit: 1), let category = categories.first else {
      fatalError()
    }
    
    for url in urls {
      guard let urlString = url.relativeString.removingPercentEncoding else {
        fatalError()
      }
      let name = url.deletingPathExtension().lastPathComponent
      // 在模擬器上 URL 會一直變化，用名字區別
      let predicate = NSPredicate(format: "%K == %@", #keyPath(Video.url), urlString)
      guard coreDataConnect.retrieve(type: Video.self, predicate: predicate, sort: nil, limit: 1) == nil else {
        // DB 中已經有該影片, do nothings
        return
      }
      // DB 中沒有該影片
      let categoiesSet = NSSet(array: [category as Any])
      do {
        try coreDataConnect.insert(type: Video.self, attributeInfo: [
          #keyPath(Video.id): coreDataConnect.generateNewID(Video.self) as Any,
          #keyPath(Video.order): coreDataConnect.generateNewOrder(Video.self) as Any,
          #keyPath(Video.url): urlString as Any,
          #keyPath(Video.savePlace): 0 as Any,
          #keyPath(Video.name): name as Any,
          #keyPath(Video.categories): categoiesSet,
        ])
      } catch {
        logger.log(error.localizedDescription, level: .error)
      }
    }
  }
  
}
