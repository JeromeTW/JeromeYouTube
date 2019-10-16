//
//  StringExtension.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/16.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation

extension String {
  func removeFileExtension() -> String {
    var components = self.components(separatedBy: ".")
    if components.count > 1 { // If there is a file extension
      components.removeLast()
      return components.joined(separator: ".")
    } else {
      return self
    }
  }
}
