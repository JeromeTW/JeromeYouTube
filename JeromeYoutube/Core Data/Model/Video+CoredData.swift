//
//  Video+CoredData.swift
//  JeromeYoutube
//
//  Created by JEROME on 2019/9/14.
//  Copyright © 2019 jerome. All rights reserved.
//

import CoreData

extension Video: HasID { }
extension Video: HasOrder { } // 數字越大在越前面，最小是 1 在最後面。
