//
//  VideoSorter.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/23.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation

struct VideoSorter {
  // TODO: Test
  static func sortVideos(_ sourceVideos: [Video], videoIDOrders: [Int]) -> [Video] {
    assert(videoIDOrders.count == sourceVideos.count)

    var IDOrderdictionary = [Int: Int]() // Key: ID, Value: Index
    for (index, value) in videoIDOrders.enumerated() {
      IDOrderdictionary[value] = index
    }

    var result = Array(repeating: Video(), count: videoIDOrders.count)

    for video in sourceVideos {
      let index = IDOrderdictionary[Int(exactly: video.id)!]!
      result[index] = video
    }
    return result
  }
}
