// TestsAppDelegate.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import UIKit

class TestsAppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  override init() {
    super.init()
    logger.configure([ .fault, .error, .debug, .info, .defaultLevel], shouldShow: false, shouldCache: true)
    logger.log("NSHomeDirectory:\(NSHomeDirectory())", level: .debug)
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UIViewController()
    window?.makeKeyAndVisible()
  }
}
