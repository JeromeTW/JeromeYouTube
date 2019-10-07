// BaseViewController.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import UIKit

class BaseViewController: UIViewController {
  // MARK: - ViewController lifecycle

  deinit {
    logger.log("\(self.className) deinit")
  }

  override func loadView() {
    logger.log("\(className) loadView")
    super.loadView()
  }

  override func viewDidLoad() {
    logger.log("\(className) viewDidLoad")
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    logger.log("\(className) viewWillAppear:")
    super.viewWillAppear(animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    logger.log("\(className) viewDidAppear:")
    super.viewDidAppear(animated)
  }

  override func viewWillLayoutSubviews() {
    logger.log("\(className) viewWillLayoutSubviews")
    super.viewWillLayoutSubviews()
  }

  override func viewDidLayoutSubviews() {
    logger.log("\(className) viewDidLayoutSubviews")
    super.viewDidLayoutSubviews()
  }

  override func viewWillDisappear(_ animated: Bool) {
    logger.log("\(className) viewWillDisappear:")
    super.viewWillDisappear(animated)
  }

  override func viewDidDisappear(_ animated: Bool) {
    logger.log("\(className) viewDidDisappear:")
    super.viewDidDisappear(animated)
  }

  // MARK: - Inherit method

  override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
    view.endEditing(true)
  }
}
