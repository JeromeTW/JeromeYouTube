//
//  WebErrorVC.swift
//  GP920_iOS
//
//  Created by Jerome.Hsieh2 on 2019/1/29.
//  Copyright © 2019 Daniel. All rights reserved.
//

import UIKit

class WebErrorVC: UIViewController {

  @IBOutlet weak var someErrorLabel: UILabel!
  @IBOutlet weak var errorDetailLabel: UILabel!
  @IBOutlet weak var tryAgainButton: UIButton!

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
