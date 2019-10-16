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
  
  static var jsonURL: URL = {
    return musicsBundle.url(forResource: "1015JeromeYouTube匯入.json", withExtension: nil)!
  }()

  static func parseJson(aJsonURL: URL) -> (categories: [String], musicsInfo: [String: String]) {
    do {
      
      let data = try Data(contentsOf: aJsonURL, options: .alwaysMapped)
      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
        fatalError()
      }
      
      guard let categories = json["categories"] as? [String] else {
        fatalError()
      }
      
      guard let musicsInfo = json["musics"] as? [String: String] else {
        fatalError()
      }
      return (categories, musicsInfo)
      
    } catch let error {
      logger.log(error.localizedDescription, level: .error)
      fatalError()
    }
  }
  
  static func addCategoriesAndVideosToDBIfNeeded(aContext: NSManagedObjectContext? = nil) {
    
    // 1. check did add CategoriesAndVideosToDB
    let key = "didAddCategoriesAndVideosToDB"
    let userdefault = UserDefaults.standard
    guard userdefault.integer(forKey: key) == 0 else {
      return
    }
    userdefault.set(1, forKey: key)

    // 2. get json data
    let result = parseJson(aJsonURL: jsonURL)
    let categoryNames = result.categories
    let musicsInfo = result.musicsInfo
    
    // 3. add categories
    let coreDataConnect = CoreDataConnect()
    // 之後可以用 NSBatchInsertRequest @available(iOS 13.0, *)
    // https://developer.apple.com/videos/play/wwdc2019/230/?time=911 // 7 分鐘左右
    coreDataConnect.insertBundleCategories(categoryNames)
    
    // 4. add videos
    coreDataConnect.insertBundleVideos(musicsInfo)
  }
  
}
