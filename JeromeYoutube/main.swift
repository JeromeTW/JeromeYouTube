// main.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import Foundation
import UIKit

/// Checks if the app is being opened by the test target
///
/// - Returns: True if the app is opened by the test target
private func isRunningTests() -> Bool {
  print("🐌 isTest:\(UserDefaults.standard.bool(forKey: "isTest"))")
  return UserDefaults.standard.bool(forKey: "isTest")
}

/// Gets the right AppDelegate class for the current environment.
/// The real AppDelegate should not be used in testing since it may have side effects.
/// Side effects include making api calls, registering for notifications, setting core data, setting UI etc.
///
/// - Returns: TestsAppDelegate if the app was opened by the test target. Normal AppDelegate otherwise.
private func getDelegateClassName() -> String {
  let moduleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
  return isRunningTests() ? NSStringFromClass(TestsAppDelegate.self) : "\(moduleName).AppDelegate"
}

/// Load the actual app with the right app delegate depending on environment
/// Based on https://marcosantadev.com/fake-appdelegate-unit-testing-swift/
_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, getDelegateClassName())
