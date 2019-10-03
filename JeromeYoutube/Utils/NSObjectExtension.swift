// NSObjectExtension.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Foundation

extension NSObject {
  static var className: String {
    return String(describing: self)
  }

  var className: String {
    return String(describing: type(of: self))
  }
}
