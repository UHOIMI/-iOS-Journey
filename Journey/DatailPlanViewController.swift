//
//  DatailPlanViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/12/06.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps

class DatailPlanViewController: UIViewController {
  
  
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var userIconImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var planNameLabel: UILabel!
  @IBOutlet weak var PrefecturesLabel: UILabel!
  @IBOutlet weak var trafficLabel: UILabel!
  @IBOutlet weak var moneyLabel: UILabel!
  @IBOutlet weak var commentTextView: UITextView!
  
  var pickOption = ["500円以下", "501円 ~ 1000円", "1001円 ~ 5000円", "5001円 ~ 10000円", "10001円以上"]
  let prefectures:Array = [ "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県", "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県", "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県", "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県","鳥取県", "島根県", "岡山県", "広島県", "山口県","徳島県", "香川県", "愛媛県", "高知県", "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県"]
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
    
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:0,width:myFrameSize.width,height:300),camera:camera)
    self.subView.addSubview(mapView)
    // Do any additional setup after loading the view.
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
  
  @IBAction func pushButton(_ sender: Any) {
    if let button = sender as? UIButton {
      if let tag = actionTag(rawValue: button.tag) {
        switch tag {
        case .action1:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_walk_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[0] = "1,"
          }else{
            button.setImage(UIImage(named: "s_walk.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[0] = "0,"
          }
        case .action2:
          if(imageFlag2 == 0){
            button.setImage(UIImage(named: "s_bicycle_on.png"), for:UIControl.State())
            imageFlag2 = 1
            transportation[1] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bicycle.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[1] = "0,"
          }
        case .action3:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_car_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[2] = "1,"
          }else{
            button.setImage(UIImage(named: "s_car.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[2] = "0,"
          }
        case .action4:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_bus_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[3] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bus.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[3] = "0,"
          }
        case .action5:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_train_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[4] = "1,"
          }else{
            button.setImage(UIImage(named: "s_train.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[4] = "0,"
          }
        case .action6:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_airplane_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[5] = "1,"
          }else{
            button.setImage(UIImage(named: "s_airplane.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[5] = "0,"
          }
        case .action7:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_boat_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[6] = "1"
          }else{
            button.setImage(UIImage(named: "s_boat.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[6] = "0"
          }
        }
      }
    }
  }
    

}
