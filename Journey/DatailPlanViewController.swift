//
//  DatailPlanViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/12/06.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation
import Photos
import CoreLocation
import CoreMotion

class DatailPlanViewController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate,UITabBarDelegate,UITextFieldDelegate,UITextViewDelegate, UITableViewDataSource,UITableViewDelegate {
  
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var userIconImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var planNameLabel: UILabel!
  @IBOutlet weak var PrefecturesLabel: UILabel!
  @IBOutlet weak var trafficLabel: UILabel!
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet weak var spotTableView: UITableView!
  @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var superViewHeight: NSLayoutConstraint!
  
  var planId = 0
  var userId = ""
  var userImage = UIImage()
  var userName = ""
  var planTitle = ""
  var planTransportationString = ""
  var planPrice = ""
  var planComment = ""
  var planArea = ""
  
  var transportation = ["0,","0,","0,","0,","0,","0,","0"]
  
  var imageFlag1 = 0
  var imageFlag2 = 0
  var imageFlag3 = 0
  var imageFlag4 = 0
  var imageFlag5 = 0
  var imageFlag6 = 0
  var imageFlag7 = 0
  
  var camera = GMSCameraPosition.camera(withLatitude: 35.710063,longitude:139.8107, zoom:15)
  var makerList : [GMSMarker] = []
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  private var tabBar:TabBar!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var arr:[String] = planTransportationString.components(separatedBy: ",")
    print(arr)
    for i in 0...6{
      let str = arr[i] + ","
      print(str)
      transportation[i] = str
      print(transportation)
    }
    
    moneyLabel.text = "1000"
    userIconImageView.image = userImage
    userNameLabel.text = userName
    planNameLabel.text = planTitle
    
    commentTextView.layer.borderColor = UIColor.gray.cgColor
    commentTextView.layer.borderWidth = 0.5
    commentTextView.layer.cornerRadius = 10.0
    commentTextView.layer.masksToBounds = true
    
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:commentTextView.frame.origin.y + commentTextView.frame.size.height + 16,width:myFrameSize.width,height:300),camera:camera)
    subView.addSubview(mapView)
    tableViewHeight.constant = 128 + 100 * 9
    superViewHeight.constant = 1280 + 100 * 9
    // Do any additional setup after loading the view.
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("セル追加")
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: SpotTableViewCell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for : indexPath) as! SpotTableViewCell
    cell.spotNameLabel.text =  "スポット名"
    cell.spotCommentLabel.text = "コメント"
    cell.spotImageView.image = UIImage(named:"画像を選択")!
//    if (spotNameListB![indexPath.row] == "nil"){
//      cell.planSpotNameLabel2.text = ""
//    }else{
//      cell.planSpotNameLabel2.text = spotNameListB![indexPath.row]
//    }
//    if(spotCountList[indexPath.row] != 0){
//      cell.planSpotCountLabel.text = "他\(spotCountList[indexPath.row])件"
//    }else{
//      cell.planSpotCountLabel.text = ""
//    }
//    print("画像パス:\(indexPath.row)",spotImagePathList![indexPath.row])
//    cell.planFavoriteLabel.text = 99999.description
//    cell.planImageView.image = spotImageList![indexPath.row]
//    cell.planDateLabel.text = dateList[indexPath.row]
//    cell.planUserIconImageView.image = userImageList[indexPath.row]
//    cell.planUserIconImageView.layer.cornerRadius = 40 * 0.5
//    print(cell.planUserIconImageView.frame.width)
//    cell.planUserIconImageView.clipsToBounds = true
//    cell.planUserNameLabel.text = userNameList[indexPath.row]
//    self.ActivityIndicator.stopAnimating()
//    planCount = indexPath.row + 1
    // 角を丸くする
    self.userIconImageView.layer.cornerRadius = 40 * 0.5
    self.userIconImageView.clipsToBounds = true
    userIconImageView.isUserInteractionEnabled = true
    userIconImageView.tag = 1
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //tableView.deselectRow(at: indexPath, animated: true)
    self.performSegue(withIdentifier: "toDetailPlanView", sender: nil)
    
  }
  
  enum actionTag: Int {
    case action1 = 1
    case action2 = 2
    case action3 = 3
    case action4 = 4
    case action5 = 5
    case action6 = 6
    case action7 = 7
  }
  
//  @IBAction func pushButton(_ sender: Any) {
//    if let button = sender as? UIButton {
//      if let tag = actionTag(rawValue: button.tag) {
//        switch tag {
//        case .action1:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_walk_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[0] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_walk.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[0] = "0,"
//          }
//        case .action2:
//          if(imageFlag2 == 0){
//            button.setImage(UIImage(named: "s_bicycle_on.png"), for:UIControl.State())
//            imageFlag2 = 1
//            transportation[1] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_bicycle.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[1] = "0,"
//          }
//        case .action3:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_car_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[2] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_car.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[2] = "0,"
//          }
//        case .action4:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_bus_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[3] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_bus.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[3] = "0,"
//          }
//        case .action5:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_train_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[4] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_train.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[4] = "0,"
//          }
//        case .action6:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_airplane_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[5] = "1,"
//          }else{
//            button.setImage(UIImage(named: "s_airplane.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[5] = "0,"
//          }
//        case .action7:
//          if(imageFlag1 == 0){
//            button.setImage(UIImage(named: "s_boat_on.png"), for:UIControl.State())
//            imageFlag1 = 1
//            transportation[6] = "1"
//          }else{
//            button.setImage(UIImage(named: "s_boat.png"), for:UIControl.State())
//            imageFlag1 = 0
//            transportation[6] = "0"
//          }
//        }
//      }
//    }
//  }
  

}
