//
//  LogTextView.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/7/29.
//  Copyright © 2019 JEROME. All rights reserved.
//

import UIKit

class LogTextView: UITextView {
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)

    setupStyle()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
    return nil
  }

  private func setupStyle() {
    backgroundColor = .white
    alpha = 0.7
    textColor = .black
  }
}
