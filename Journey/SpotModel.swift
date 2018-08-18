//
//  SpotModel.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/18.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//
import Foundation
import RealmSwift

class SpotModel: Object {
  
  @objc dynamic var spot_id : Int = 0;
  @objc dynamic var spot_name = "";
  @objc dynamic var latitude : Float = 0.0;
  @objc dynamic var longitude : Float = 0.0;
  @objc dynamic var comment = "";
  @objc dynamic var datetime = Data();
  @objc dynamic var image_A = "";
  @objc dynamic var image_B = "";
  @objc dynamic var image_C = "";
  
  override static func primaryKey() -> String? {
    return "spot_id"
  }
  
}
