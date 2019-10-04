//
//  UIAlertController+Picker.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/3.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit

class AlertControllerWithPicker: UIAlertController {
  var choices: [String]!
  var didSelectedHandler: ((String) -> Void)!
  private var pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
  
  override func loadView() {
    super.loadView()
    assert(choices != nil)
    assert(didSelectedHandler != nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(pickerView)
    preferredContentSize.height = pickerView.frame.height + 40
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
