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
  /*var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var name: String
  var date: Date
  var databaseId: Int*/
    var spot_id : Int
    var spot_name: String
    var latitude : Double
    var longitude : Double
    var comment : String
    var datetime : Date
    var image_A : String
    var image_B : String
    var image_C : String
    
  
  override init() {
    /*latitude = 0.0
    longitude = 0.0
    name = "未入力"
    date = Date()
    databaseId = 0*/
    
    spot_id = 0
    spot_name = "未入力"
    latitude = 0.0
    longitude = 0.0
    comment = ""
    datetime = Date()
    image_A = ""
    image_B = ""
    image_C = ""
  }
    
    init(sm : SpotModel) {
        spot_id = sm.spot_id
        spot_name = sm.spot_name
        latitude = sm.latitude
        longitude = sm.longitude
        comment = sm.comment
        datetime = sm.datetime
        image_A = sm.image_A
        image_B = sm.image_B
        image_C = sm.image_C
    }
    
    init(la : CLLocationDegrees, lo : CLLocationDegrees , na : String) {
        spot_id = 0
        spot_name = na
        latitude = la
        longitude = lo
        comment = ""
        datetime = Date()
        image_A = ""
        image_B = ""
        image_C = ""
    }
  
  /*init(la : CLLocationDegrees, lo : CLLocationDegrees , na : String) {
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
  }*/
}
