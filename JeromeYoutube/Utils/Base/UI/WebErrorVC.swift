// WebErrorVC.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/3.

import UIKit

class WebErrorVC: UIViewController {
  @IBOutlet var someErrorLabel: UILabel!
  @IBOutlet var errorDetailLabel: UILabel!
  @IBOutlet var tryAgainButton: UIButton!

  var tryAgainHandler: (() -> Void)!

  override func viewDidLoad() {
    super.viewDidLoad()
    someErrorLabel.text = "webViewErrorTitle"
    errorDetailLabel.text = "webViewErrorContent"
    tryAgainButton.setTitle("webViewErrorTryAgain", for: .normal)
//    tryAgainButton.setTitleColor(UIColor(.enterpriseWhite), for: .normal)
//    tryAgainButton.backgroundColor = UIColor(.enterpriseBlue)
    tryAgainButton.layer.cornerRadius = 5
    tryAgainButton.addTarget(self, action: #selector(tryAgainButtonPressed), for: .touchUpInside)
  }

  @objc func tryAgainButtonPressed() {
    tryAgainHandler()
  }
}
