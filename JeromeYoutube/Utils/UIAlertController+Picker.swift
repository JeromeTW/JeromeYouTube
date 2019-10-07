// UIAlertController+Picker.swift
// Copyright (c) 2019 Jerome Hsieh. All rights reserved.
// Created by Jerome Hsieh on 2019/10/5.

import SnapKit
import UIKit

class AlertControllerWithPicker<T>: UIAlertController, UIPickerViewDataSource, UIPickerViewDelegate {
  var objects: [T]!
  var didSelectedObject: T!
  var titleStringKeyPath: ReferenceWritableKeyPath<T, String>!
  private var pickerView = UIPickerView(frame: CGRect.zero)

  override func loadView() {
    super.loadView()
    assert(objects != nil)
    assert(titleStringKeyPath != nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    assert(objects.isEmpty == false)
    view.addSubview(pickerView)
    pickerView.snp.makeConstraints { make in
      make.left.equalTo(view).offset(0)
      make.right.equalTo(view).offset(0)
      make.top.equalTo(view).offset(80) // Tuning 出來的 Magic Number
      make.height.equalTo(view.bounds.height * 0.2) // Tuning 出來的 Magic Number
    }
    pickerView.dataSource = self
    pickerView.delegate = self
    didSelectedObject = objects[0]
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  func numberOfComponents(in _: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
    return objects.count
  }

  func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
    return objects[row][keyPath: titleStringKeyPath]
  }

  func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
    didSelectedObject = objects[row]
  }
}

// NOTE: CANNOT Make an extensions of generic class in Swift5
// https://stackoverflow.com/a/48403602/4593553
