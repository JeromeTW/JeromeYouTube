//
//  UIAlertController+Picker.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/3.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import SnapKit

class AlertControllerWithPicker: UIAlertController {
  var choices: [String]!
  var didSelectedHandler: ((String) -> Void)!
  private var pickerView = UIPickerView(frame: CGRect.zero)
  
  override func loadView() {
    super.loadView()
    assert(choices != nil)
    assert(didSelectedHandler != nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(pickerView)
    pickerView.snp.makeConstraints { make in
      make.edges.equalTo(view).inset(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
    }
    pickerView.dataSource = self
    pickerView.delegate = self
  }
}

extension AlertControllerWithPicker: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return choices.count
  }
}

extension AlertControllerWithPicker: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return choices[row]
  }
      
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      didSelectedHandler(choices[row])
  }
}
