//
//  BaseViewController.swift
//  DDTDemo
//
//  Created by Allen Lai on 2019/7/29.
//  Copyright © 2019 Allen Lai. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
  // MARK: - ViewController lifecycle
  deinit {
    logger.log("\(self.className) deinit")
  }
  
  override func loadView() {
    logger.log("\(self.className) loadView")
    super.loadView()
    
  }
  
  override func viewDidLoad() {
    logger.log("\(self.className) viewDidLoad")
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    logger.log("\(self.className) viewWillAppear:")
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    logger.log("\(self.className) viewDidAppear:")
    super.viewDidAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    logger.log("\(self.className) viewWillLayoutSubviews")
    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLayoutSubviews() {
    logger.log("\(self.className) viewDidLayoutSubviews")
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    logger.log("\(self.className) viewWillDisappear:")
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    logger.log("\(self.className) viewDidDisappear:")
    super.viewDidDisappear(animated)
  }
  
  // MARK: - Inherit method
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
