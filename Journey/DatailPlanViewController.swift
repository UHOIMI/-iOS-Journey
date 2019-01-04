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
  
  let globalVar = GlobalVar.shared
  
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
  @IBOutlet weak var walkImageView: UIImageView!
  @IBOutlet weak var bicycleImageView: UIImageView!
  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var busImageView: UIImageView!
  @IBOutlet weak var trainImageView: UIImageView!
  @IBOutlet weak var boatImageView: UIImageView!
  @IBOutlet weak var airplaneImageView: UIImageView!
  
  var spotIdList : [Int] = []
  var planIdList : [Int] = []
  var spotTitleList : [String] = []
  var planTitleList : [String] = []
  var spotCommentList : [String] = []
  var spotImageAList : [UIImage] = []
  var spotImageBList : [UIImage] = []
  var spotImageCList : [UIImage] = []
  var spotImageSetFlag : [Int] = []
  
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
    for i in 0 ... 2 {
      makerList.insert(GMSMarker(), at: i)
    }
    getSpot()
    var arr:[String] = planTransportationString.components(separatedBy: ",")
    print(arr)
    for i in 0...6{
      if(i != 6){
        let str = arr[i] + ","
        print(str)
        transportation[i] = str
        print(transportation)
      }else{
        transportation[i] = arr[i]
      }
    }
    if(transportation[0] == "1,"){
      walkImageView.image = UIImage(named: "s_walk_on.png")
    }
    if(transportation[1] == "1,"){
      bicycleImageView.image = UIImage(named: "s_bicycle_on.png")
    }
    if(transportation[2] == "1,"){
      carImageView.image = UIImage(named: "s_car_on.png")
    }
    if(transportation[3] == "1,"){
      busImageView.image = UIImage(named: "s_bus_on.png")
    }
    if(transportation[4] == "1,"){
      trainImageView.image = UIImage(named: "s_train_on.png")
    }
    if(transportation[5] == "1,"){
      boatImageView.image = UIImage(named: "s_boat_on.png")
    }
    if(transportation[6] == "1"){
      airplaneImageView.image = UIImage(named: "s_airplane_on.png")
    }
    
    commentTextView.text = planComment
    PrefecturesLabel.text = planArea
    moneyLabel.text = planPrice
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
    createTabBar()
    // Do any additional setup after loading the view.
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("テーブルの数", spotTitleList.count)
    return spotTitleList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: SpotTableViewCell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for : indexPath) as! SpotTableViewCell
    cell.spotNameLabel.text =  spotTitleList[indexPath.row]
    cell.spotImageView.image = spotImageAList[indexPath.row]
    cell.spotCommentLabel.text =  spotCommentList[indexPath.row]
//    cell.spotNameLabel.text =  "スポット名"
//    cell.spotCommentLabel.text = "コメント"
//    cell.spotImageView.image = UIImage(named:"画像を選択")!
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
  
  struct SpotData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let spotAddress : SpotAddress
      let spotId : Int
      let planId : Int
      let spotTitle : String
      let spotComment : String?
      let spotImageA : String?
      let spotImageB : String?
      let spotImageC : String?
      enum CodingKeys: String, CodingKey {
        case spotAddress = "spot_address"
        case spotId = "spot_id"
        case planId = "plan_id"
        case spotTitle = "spot_title"
        case spotComment = "spot_comment"
        case spotImageA = "spot_image_a"
        case spotImageB = "spot_image_b"
        case spotImageC = "spot_image_c"
      }
      struct SpotAddress : Codable{
        let lat : Double
        let lng : Double
        enum CodingKeys: String, CodingKey {
          case lat = "lat"
          case lng = "lng"
        }
      }
    }
  }
  
  func getSpot(){
    var text = "http://\(globalVar.ipAddress)/api/v1/spot/find?spot_id=143&spot_id=146"
    text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    //    let decodedString:String = text.removingPercentEncoding!
    print("URLのテスト", text)
    let url = URL(string: text)!
    let request = URLRequest(url: url)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let spotData = try? JSONDecoder().decode(SpotData.self, from: data)
        if(spotData!.status == 200){
          for i in 0 ... (spotData?.record?.count)! - 1{
//                1var count = 0
            //self.makerList.insert(GMSMarker(), at: i)
            //let test = (spotData?.record![i].spotAddress.lat)!
            //let test2 = (spotData?.record![i].spotAddress.lat)!
            self.makerList[i].position = CLLocationCoordinate2D(latitude: (spotData?.record![i].spotAddress.lat)!, longitude: (spotData?.record![i].spotAddress.lng)!)
            self.spotIdList.insert((spotData?.record![i].spotId)!, at: i)
            self.planIdList.insert((spotData?.record![i].planId)!, at: i)
            self.spotTitleList.insert((spotData?.record![i].spotTitle)!, at: i)
            self.spotCommentList.insert((spotData?.record![i].spotComment)!, at: i)
            if((spotData?.record![i].spotImageA)! != ""){
              let url = URL(string: (spotData?.record![i].spotImageA)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageAList.append(image!)
            }else{
              self.spotImageAList.append(UIImage(named:"no-image.png")!)
            }
            if((spotData?.record![i].spotImageB)! != ""){
              let url = URL(string: (spotData?.record![i].spotImageB)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageBList.append(image!)
            }else{
              self.spotImageBList.append(UIImage(named:"no-image.png")!)
            }
            if((spotData?.record![i].spotImageC)! != ""){
              let url = URL(string: (spotData?.record![i].spotImageC)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageCList.append(image!)
            }else{
              self.spotImageCList.append(UIImage(named:"no-image.png")!)
            }
//            var url = URL(string: (spotData?.record![i].spotImageA)!)!
//            var imageData = try? Data(contentsOf: url)
//            var image = UIImage(data:imageData!)
//            self.spotImageAList.append(image!)
//            url = URL(string: (spotData?.record![i].spotImageB)!)!
//            imageData = try? Data(contentsOf: url)
//            image = UIImage(data:imageData!)
//            self.spotImageBList.append(image!)
//            url = URL(string: (spotData?.record![i].spotImageC)!)!
//            imageData = try? Data(contentsOf: url)
//            image = UIImage(data:imageData!)
//            self.spotImageCList.append(image!)
          }
          
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print("リロードテーブル")
            self.spotTableView.reloadData()
          }
        }else{
          print("status",spotData!.status)
        }
      }
    }.resume()
  }
  
  func createTabBar(){
    let width = self.view.frame.width
    let height = self.view.frame.height
    //デフォルトは49
    let tabBarHeight:CGFloat = 58
    /**   TabBarを設置   **/
    tabBar = TabBar()
    if UIDevice().userInterfaceIdiom == .phone {
      switch UIScreen.main.nativeBounds.height {
      case 2436:
        tabBar.frame = CGRect(x:0,y:height - tabBarHeight - 34.1,width:width,height:tabBarHeight)
      default:
        tabBar.frame = CGRect(x:0,y:height - tabBarHeight,width:width,height:tabBarHeight)
      }
    }
    //バーの色
    tabBar.barTintColor = UIColor.lightGray
    //選択されていないボタンの色
    tabBar.unselectedItemTintColor = UIColor.black
    //ボタンを押した時の色
    tabBar.tintColor = UIColor.black
    //ボタンを生成
    let home:UITabBarItem = UITabBarItem(title: "home", image: UIImage(named:"home.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 1)
    let search:UITabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
    let favorites:UITabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
    let setting:UITabBarItem = UITabBarItem(title: "setting", image: UIImage(named:"settings.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 4)
    //ボタンをタブバーに配置する
    tabBar.items = [home,search,favorites,setting]
    //デリゲートを設定する
    tabBar.delegate = self
    
    self.view.addSubview(tabBar)
  }
  
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    switch item.tag{
    case 1:
      print("１")
    case 2:
      print("２")
    case 3:
      print("３")
    case 4:
      performSegue(withIdentifier: "backDetailUserView", sender: nil)
    default : return
      
    }
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
