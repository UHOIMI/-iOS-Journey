//
//  UserModel.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/01.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import Foundation
import RealmSwift

class UserModel: Object {
  
  @objc dynamic var user_id : String = "";
  @objc dynamic var user_name : String = "";
  @objc dynamic var user_pass : String = "";
  @objc dynamic var user_generation : Int = 0;
  @objc dynamic var user_gender : String = "";
  @objc dynamic var user_comment : String = "";
  @objc dynamic var user_image : String = "";
  @objc dynamic var user_header : String = "";
  @objc dynamic var user_token : String = "";
  
  override static func primaryKey() -> String? {
    return "user_id"
  }
  
}
