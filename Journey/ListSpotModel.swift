//
//  ListSpotModel.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/18.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//
import UIKit
import CoreLocation

class ListSpotModel: NSObject {
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var name: String
  var date: Date
  var databaseId: Int
  
  override init() {
    latitude = 0.0
    longitude = 0.0
    name = "未入力"
    date = Date()
    databaseId = 0
  }
  
  init(la : CLLocationDegrees, lo : CLLocationDegrees , na : String) {
    latitude = la
    longitude = lo
    name = na
    date = Date()
    databaseId = 0
  }
  
  init(la : CLLocationDegrees, lo : CLLocationDegrees , na : String, id : Int) {
    latitude = la
    longitude = lo
    name = na
    date = Date()
    databaseId = id
  }
}
