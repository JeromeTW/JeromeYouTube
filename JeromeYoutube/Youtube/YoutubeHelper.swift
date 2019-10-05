// YoutubeHelper.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

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
      return .failure(GrabYoutubeIDError.invalied)
    }
    return .success(text.components(separatedBy: parameterSeparator)[1])
  }

  static func add(_ youtubeID: String, to category: VideoCategory) throws {
    let coredataConnect = CoreDataConnect()
    try coredataConnect.insert(type: Video.self, attributeInfo: [
      #keyPath(Video.id): coredataConnect.generateNewID(Video.self) as Any,
      #keyPath(Video.order): coredataConnect.generateNewOrder(Video.self) as Any,
      #keyPath(Video.youtubeID): youtubeID as Any,
      #keyPath(Video.category): category as Any,
    ])
    let videoPredicate = NSPredicate(format: "%K == %@", #keyPath(Video.youtubeID), youtubeID)
    guard let video = coredataConnect.retrieve(type: Video.self, predicate: videoPredicate, sort: nil, limit: 1)?.first else {
      return
    }
//    youtubePlayer.video = video
  }
  
  enum GrabYoutubeIDError: Error {
    case invalied
  }
}
