//
//  YoutubeHelper.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/14.
//  Copyright © 2019 jerome. All rights reserved.
//

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
  
  enum GrabYoutubeIDError: Error {
    case invalied
  }
}
