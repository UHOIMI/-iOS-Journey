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
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var subViewHeight: NSLayoutConstraint!
//  @IBOutlet weak var userBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var userIconImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var planNameLabel: UILabel!
  @IBOutlet weak var PrefecturesLabel: UILabel!
  @IBOutlet weak var trafficLabel: UILabel!
  @IBOutlet weak var moneyLabel: UILabel!
//  @IBOutlet weak var commentTextView: UITextView!
  @IBOutlet weak var commentLabel: UILabel!
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
  @IBOutlet weak var favoriteButton: UIButton!  
  @IBOutlet weak var planDeleteButton: UIBarButtonItem!
  
  var spotIdList : [Int] = []
  var planIdList : [Int] = []
  var spotLatList : [Double] = []
  var spotLngList : [Double] = []
  var spotTitleList : [String] = []
  var planTitleList : [String] = []
  var spotCommentList : [String] = []
  var spotImageAList : [UIImage] = []
  var spotImageBList : [UIImage] = []
  var spotImageCList : [UIImage] = []
  var spotImageNum : [Int] = []
  var spotImagePathList : [String] = []
  
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
  
  var viewHeight = 1000
  var spotNum = 0
  var favoriteFlag = false
  var detailePlanFlag = false
  var camera = GMSCameraPosition.camera(withLatitude: 35.710063,longitude:139.8107, zoom:15)
  var makerList : [GMSMarker] = []
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  private var tabBar:TabBar!
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
//    self.navigationItem.hidesBackButton = true
    if(globalVar.userId != userId){
      planDeleteButton.title = ""
      planDeleteButton.isEnabled = false
    }
    viewHeight = Int(spotTableView.frame.origin.y) + 100
    getSpot()
//    for i in 0 ... spotLatList.count {
//      makerList.insert(GMSMarker(), at: i)
//      spotImageNum.insert(-1, at: i)
//      makerList[i].position = CLLocationCoordinate2D(latitude: spotLatList[i], longitude: spotLngList[i])
//    }
    getFavorite()
    var arr:[String] = planTransportationString.components(separatedBy: ",")
    print(arr)
    for i in 0...6{
      if(i != 6){
        print("トランスポーテーション", arr)
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
    
    commentLabel.text = planComment
    PrefecturesLabel.text = planArea
    moneyLabel.text = planPrice
    userIconImageView.image = userImage
    userNameLabel.text = userName
    planNameLabel.text = planTitle
    
    commentLabel.numberOfLines = 0 //折り返し
    commentLabel.sizeToFit() //サイズを文字列に合わせる
    commentLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
    
//    commentTextView.layer.borderColor = UIColor.gray.cgColor
//    commentTextView.layer.borderWidth = 0.5
//    commentTextView.layer.cornerRadius = 10.0
//    commentTextView.layer.masksToBounds = true

//    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:commentTextView.frame.origin.y + commentTextView.frame.size.height + 16,width:myFrameSize.width,height:300),camera:camera)
//    for i in 0 ..< self.spotIdList.count - 1{
//      self.makerList[i].map = mapView
//    }
//    subView.addSubview(mapView)
    tableViewHeight.constant = 128 + 100 * 9
    superViewHeight.constant = 1280 + 100 * 9
    
//    let leftButton: UIButton = UIButton()
//    leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//    leftButton.setImage(globalVar.userIcon, for: UIControl.State.normal)
//    leftButton.imageView?.layer.cornerRadius = 40 * 0.5
//    leftButton.imageView?.clipsToBounds = true
//    leftButton.addTarget(self, action: #selector(DatailPlanViewController.userIconTapped(sender:)), for: .touchUpInside)
//    userBarButtonItem.customView = leftButton
//    userBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
//    userBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    
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
    return spotImageCList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: SpotTableViewCell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for : indexPath) as! SpotTableViewCell
    cell.spotNameLabel.text =  spotTitleList[indexPath.row]
    switch spotImageNum[indexPath.row] {
    case 0:
      cell.spotImageView.image = spotImageAList[indexPath.row]
      break
    case 1:
      cell.spotImageView.image = spotImageBList[indexPath.row]
      break
    default:
      cell.spotImageView.image = spotImageCList[indexPath.row]
    }
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
    print("テーブータップ")
    self.spotNum = indexPath.row
    self.performSegue(withIdentifier: "toDetailSpotView", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "toDetailSpotView"){
      let nextViewController = segue.destination as! DetailSpotViewController
      let listSpotModel = ListSpotModel()
      listSpotModel.spot_id = self.spotIdList[spotNum]
      listSpotModel.spot_name = self.spotTitleList[spotNum]
      listSpotModel.latitude = self.spotLatList[spotNum]
      listSpotModel.longitude = self.spotLngList[spotNum]
      listSpotModel.comment = self.spotCommentList[spotNum]
      listSpotModel.datetime = Date()
      listSpotModel.image_A = "Another"
      listSpotModel.image_B = "Another"
      listSpotModel.image_C = "Another"
      let postImages = [spotImageAList[spotNum], spotImageBList[spotNum], spotImageCList[spotNum]]
      nextViewController.getImages = postImages
      nextViewController.spotData = listSpotModel
      nextViewController.editFlag = true

//      spotIdList2.removeAll()
      
    }else if(segue.identifier == "toDetailUserView"){
      let nextViewController = segue.destination as! DetailUserViewController
      if(userId != globalVar.userId && detailePlanFlag == false){
        nextViewController.editFlag = false
      }
    }else if(segue.identifier == "toTimelineView"){
      let nextView = segue.destination as! TimelineViewController
      nextView.favoriteFlag = 1
    }
  }
  
  
  @IBAction func tappedFavoriteButton(_ sender: Any) {
    postFavorite()
    //getFavorite()
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
  
  struct FavoriteData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let favDate : String
      let planId : Int
      let userId : String
      enum CodingKeys: String, CodingKey {
        case favDate = "fav_date"
        case planId = "plan_id"
        case userId = "user_id"
      }
    }
  }
  
  func getSpot(){
    var text = "http://\(globalVar.ipAddress)/api/v1/spot/find?plan_id=\(planId)"
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
            //self.makerList.insert(GMSMarker(), at: i)
            self.spotImageNum.insert(-1, at: i)
            self.spotLatList.insert((spotData?.record![i].spotAddress.lat)!, at: i)
            self.spotLngList.insert((spotData?.record![i].spotAddress.lng)!, at: i)
//            self.makerList[i].position = CLLocationCoordinate2D(latitude: (spotData?.record![i].spotAddress.lat)!, longitude: (spotData?.record![i].spotAddress.lng)!)
            self.spotIdList.insert((spotData?.record![i].spotId)!, at: i)
            self.planIdList.insert((spotData?.record![i].planId)!, at: i)
            self.spotTitleList.insert((spotData?.record![i].spotTitle)!, at: i)
            self.spotCommentList.insert((spotData?.record![i].spotComment)!, at: i)
            if((spotData?.record![i].spotImageA)! != ""){
              self.spotImagePathList.append((spotData?.record![i].spotImageA)!)
              let url = URL(string: (spotData?.record![i].spotImageA)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageAList.append(image!)
              if(self.spotImageNum[i] == -1){
                self.spotImageNum[i] = 0
              }
            }else{
              self.spotImageAList.append(UIImage(named:"no-image.png")!)
            }
            if((spotData?.record![i].spotImageB)! != ""){
              self.spotImagePathList.append((spotData?.record![i].spotImageB)!)
              let url = URL(string: (spotData?.record![i].spotImageB)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageBList.append(image!)
              if(self.spotImageNum[i] == -1){
                self.spotImageNum[i] = 1
              }
            }else{
              self.spotImageBList.append(UIImage(named:"no-image.png")!)
            }
            if((spotData?.record![i].spotImageC)! != ""){
              self.spotImagePathList.append((spotData?.record![i].spotImageC)!)
              let url = URL(string: (spotData?.record![i].spotImageC)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageCList.append(image!)
            }else{
              self.spotImageCList.append(UIImage(named:"no-image.png")!)
            }
            if(self.spotImageNum[i] == -1){
              self.spotImageNum[i] = 2
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
            
            for i in 0 ... self.spotLatList.count - 1 {
              self.makerList.insert(GMSMarker(), at: i)
              //      spotImageNum.insert(-1, at: i)
              self.makerList[i].position = CLLocationCoordinate2D(latitude: self.spotLatList[i], longitude: self.spotLngList[i])
            }
            print("リロードテーブル")
            self.viewHeight += 100 * self.spotImageCList.count
            self.subViewHeight.constant = CGFloat(self.viewHeight)
            self.subView.frame = CGRect(x:0, y: 0, width:375, height:self.viewHeight)
            self.spotTableView.reloadData()
            self.camera = GMSCameraPosition.camera(withLatitude: self.makerList[0].position.latitude,longitude:self.makerList[0].position.longitude, zoom:15)
            let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + 16,width:self.myFrameSize.width,height:300),camera:self.camera)
            print("commentTextView.frame.origin.yはああ", self.commentLabel.frame.origin.y)
            print("spotisカウント", self.spotTitleList.count)
            for i in 0 ... (self.spotTitleList.count - 1){
              print("spotidは", self.spotTitleList[i])
              self.makerList[i].map = mapView
            }
            self.subView.addSubview(mapView)
            
          }
        }else{
          print("status",spotData!.status)
        }
        print(self.spotIdList)
      }
      }.resume()
  }
  
  func getFavorite(){
    var text = "http://\(globalVar.ipAddress)/api/v1/favorite/find?plan_id=\(planId)&user_id=\(globalVar.userId)"
    text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
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
        let favoriteData = try? JSONDecoder().decode(FavoriteData.self, from: data)
          if(favoriteData!.status == 200){
            self.favoriteFlag = true
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
              self.favoriteButton.setImage(UIImage(named:"onstar")!, for: .normal)
            }
          }else if(favoriteData!.status == 404){
            self.favoriteFlag = false
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
              self.favoriteButton.setImage(UIImage(named:"offstar")!, for: .normal)
            }
          }else{
            print("status",favoriteData!.status)
          }
        
      }
    }.resume()
  }
  
  func postFavorite(){
    if(!favoriteFlag) {
      let str : String = "token=\(globalVar.token)&plan_id=\(planId)"
      print("うらるstr:",str)
      let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/favorite/register")
      var request = URLRequest(url: url!)
      // POSTを指定
      request.httpMethod = "POST"
      // POSTするデータをBodyとして設定
      request.httpBody = str.data(using: .utf8)
      let session = URLSession.shared
      session.dataTask(with: request) { (data, response, error) in
        if error == nil, let data = data, let response = response as? HTTPURLResponse {
          // HTTPヘッダの取得
          print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
          // HTTPステータスコード
          print("statusCode: \(response.statusCode)")
          print(String(data: data, encoding: .utf8) ?? "")
          
        }
        self.getFavorite()
      }.resume()
    }else{
      let str : String = "token=\(globalVar.token)&plan_id=\(planId)"
      print("うらるstr:",str)
//      let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/favorite/delete")
      let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/favorite/delete")

//      print("デリートウラル：", url)
      var request = URLRequest(url: url!)
      // DELETEを指定
      request.httpMethod = "DELETE"
      //request.setValue(str.data(using: .utf8)?.count.description, forHTTPHeaderField: "Content-Length")
      // DELETEするデータをBodyとして設定
      request.httpBody = str.data(using: .utf8)
//      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//      request.addValue("application/json", forHTTPHeaderField: "Accept")
//      request.addValue("\(request.httpBody!.count)", forHTTPHeaderField: "Content-Length")
//      request.addValue("\(str.)", forHTTPHeaderField: "Content-Length")
      
      // マルチパートでファイルアップロード
//      let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
//      let urlConfig = URLSessionConfiguration.default
//      urlConfig.httpAdditionalHeaders = headers
      
//      let session = Foundation.URLSession(configuration: urlConfig)
//      print("ヘッダー", request.allHTTPHeaderFields)
      
      let session = URLSession.shared
      session.dataTask(with: request) { (data, response, error) in
        if error == nil, let data = data, let response = response as? HTTPURLResponse {
          // HTTPヘッダの取得
          print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
          // HTTPステータスコード
          print("statusCode: \(response.statusCode)")
          print(String(data: data, encoding: .utf8) ?? "")
          
        }
        self.getFavorite()
      }.resume()
    }
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
      performSegue(withIdentifier: "toStartView", sender: nil)
    case 2:
      performSegue(withIdentifier: "toSearchView", sender: nil)
    case 3:
      performSegue(withIdentifier: "toTimelineView", sender: nil)
    case 4:
      detailePlanFlag = true
      performSegue(withIdentifier: "toDetailUserView", sender: nil)
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
  
  @objc func userIconTapped(sender : AnyObject) {
    deleteSpot(planId: planId)
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
  }
  
  @IBAction func tappedDeleteButton(_ sender: Any) {
    for _image in spotImagePathList{
      let imageName = _image.components(separatedBy: "/")
      deleteImage(imageName: imageName[2])
    }
    deleteSpot(planId: planId)
  }
  
  func deleteImage(imageName:String){
    let str : String = "token=\(globalVar.token)&image_name=\(imageName)"
    let url = URL(string: "http://api.mino.asia:3001/api/v1/image/delete?token=\(globalVar.token)&image_name=\(imageName)")
    var request = URLRequest(url: url!)
    // DELETEを指定
    request.httpMethod = "DELETE"
    // DELETEするデータをBodyとして設定
    request.httpBody = str.data(using: .utf8)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: .utf8) ?? "")
      }
      }.resume()
  }
  
  func deleteSpot(planId:Int){
    let str : String = "token=\(globalVar.token)&plan_id=\(planId)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/spot/delete?token=\(globalVar.token)&plan_id=\(planId)")
    var request = URLRequest(url: url!)
    // DELETEを指定
    request.httpMethod = "DELETE"
    // DELETEするデータをBodyとして設定
    guard let unwrapped = str.data(using: .utf8) else { return }
    print (unwrapped)
    request.httpBody = unwrapped
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: .utf8) ?? "")
        self.deletePlan(planId: planId)
      }
    }.resume()
  }
  func deletePlan(planId:Int){
    let str : String = "plan_id=\(planId)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/plan/delete?token=\(globalVar.token)&plan_id=\(planId)")
    var request = URLRequest(url: url!)
    // DELETEを指定
    request.httpMethod = "DELETE"
    // DELETEするデータをBodyとして設定
    request.httpBody = str.data(using: .utf8)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: .utf8) ?? "")
        self.globalVar.userPostPlan(userId: self.globalVar.userId)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +  1.0) {
          self.performSegue(withIdentifier: "toDetailUserView", sender: nil)
        }
      }
      }.resume()
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
