// TestsAppDelegate.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import UIKit

class TestsAppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  override init() {
    super.init()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UIViewController()
    window?.makeKeyAndVisible()
  }
}
