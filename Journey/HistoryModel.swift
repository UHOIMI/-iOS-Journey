//
//  HistoryModel.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/27.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryModel: Object {
  
  @objc dynamic var history_id : String = NSUUID().uuidString
  @objc dynamic var history_word = ""
  @objc dynamic var datetime = Date()
  
  override static func primaryKey() -> String? {
    return "history_id"
  }
  
}
