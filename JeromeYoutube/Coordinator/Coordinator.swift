// Coordinator.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit

protocol Coordinator: AnyObject {
  var navigationController: CoordinatedNavigationController { get set }
}

/// A navigation controller that is aware of its coordinator. This is used extremely rarely through UIResponder-Coordinated.swift, for when we need to find the coordinator responsible for a specific view.
class CoordinatedNavigationController: UINavigationController {
  weak var coordinator: Coordinator?

  // 1: N T V -> V N T
  // ViewDidLoad -> ViewDidAppeard
  // 2: T N V    -> T N V
}
