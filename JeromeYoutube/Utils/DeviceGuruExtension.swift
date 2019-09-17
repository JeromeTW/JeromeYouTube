//
//  DeviceGuruExtension.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/17.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation
import  DeviceGuru

extension DeviceGuru {
  var hasSensorHousing: Bool {
    let deviceGuru = DeviceGuru()
    let deviceName = deviceGuru.hardware()
    let hasSensorHousingDevices: [Hardware] = [.iphoneX, .iphoneXS, .iphoneXSMax, .iphoneXSMaxChina, .iphoneXR]
    return hasSensorHousingDevices.contains(deviceName)
  }
}
