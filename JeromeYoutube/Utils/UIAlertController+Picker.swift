//
//  UIAlertController+Picker.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/10/3.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import SnapKit

class AlertControllerWithPicker<T>: UIAlertController, UIPickerViewDataSource, UIPickerViewDelegate {
  var choices: [T]!
  var didSelectedString: T!
  var titleStringKeyPath: ReferenceWritableKeyPath<T, String>!
  private var pickerView = UIPickerView(frame: CGRect.zero)
  
  override func loadView() {
    super.loadView()
    assert(choices != nil)
    assert(titleStringKeyPath != nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(choices.isEmpty == false)
    view.addSubview(pickerView)
    pickerView.snp.makeConstraints { make in
      make.left.equalTo(view).offset(0)
      make.right.equalTo(view).offset(0)
      make.top.equalTo(view).offset(80) // Tuning 出來的 Magic Number
      make.height.equalTo(view.bounds.height * 0.2) // Tuning 出來的 Magic Number
    }
    pickerView.dataSource = self
    pickerView.delegate = self
    didSelectedString = choices[0]
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return choices.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return choices[row][keyPath: titleStringKeyPath]
  }
      
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    didSelectedString = choices[row]
  }
}

// NOTE: CANNOT Make an extensions of generic class in Swift5
// https://stackoverflow.com/a/48403602/4593553
