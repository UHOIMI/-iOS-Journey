//
//  TimelineViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/21.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import UIKit
import GoogleMaps
import Foundation
import Photos
import CoreLocation
import CoreMotion
import RealmSwift

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

  @IBOutlet weak var tableView: UITableView!
  var ActivityIndicator: UIActivityIndicatorView!
  let formatter = DateFormatter()
  
  let globalVar = GlobalVar.shared
  private var tabBar:TabBar!
  
  var sampledatas = [1,2,3,4,5,6,7,8,9,10]
  var isaddload:Bool = true
  var planIdList : [Int] = []
  var userIdList : [String] = []
  var userNameList : [String] = []
  var planTitleList : [String] = []
  var userImagePathList : [String] = []
  var dateList : [String] = []
  var spotImageSetFlag : [Int] = []
  var spotCountList : [Int] = []
  var spotNameListA : [String] = []
  var spotNameListB : [String]? = []
  var spotImagePathList : [String]? = []
  var trueSpotImagePathList : [String]? = []
  var spotImageList : [UIImage]? = []
  var userImageList : [UIImage] = []
  var planCount = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getTimeline(offset: 0)
//    tableView.reloadData()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    tableView.register(cellType: LoaddingTableViewCell.self)
    let footerCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoaddingTableViewCell")!
    (footerCell as! LoaddingTableViewCell).startAnimationg()
    let footerView: UIView = footerCell.contentView
    tableView.tableFooterView = footerView
    tableView.addSubview(refreshControl)
    // ActivityIndicatorを作成＆中央に配置
    ActivityIndicator = UIActivityIndicatorView()
    ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    ActivityIndicator.center = self.view.center
    
    // クルクルをストップした時に非表示する
    ActivityIndicator.hidesWhenStopped = true
    
    // 色を設定
    ActivityIndicator.style = UIActivityIndicatorView.Style.gray
    
    //Viewに追加
    self.view.addSubview(ActivityIndicator)
    ActivityIndicator.startAnimating()
    
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
//    tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return planTitleList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: PlanTableViewCell = tableView.dequeueReusableCell(withIdentifier: "planCell", for : indexPath) as! PlanTableViewCell
    //let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath)
    cell.isUserInteractionEnabled = true
    cell.planNameLabel.text =  planTitleList[indexPath.row]
    cell.planSpotNameLabel1.text = spotNameListA[indexPath.row]
    if (spotNameListB![indexPath.row] == "nil"){
      cell.planSpotNameLabel2.text = ""
    }else{
      cell.planSpotNameLabel2.text = spotNameListB![indexPath.row]
    }
    if(spotCountList[indexPath.row] != 0){
      cell.planSpotCountLabel.text = "他\(spotCountList[indexPath.row])件"
    }else{
      cell.planSpotCountLabel.text = ""
    }
//    print("画像パス:\(indexPath.row)",spotImagePathList![indexPath.row])
    cell.planFavoriteLabel.text = 99999.description
    cell.planImageView.image = spotImageList![indexPath.row]
    cell.planDateLabel.text = dateList[indexPath.row]
    cell.planUserIconImageView.image = userImageList[indexPath.row]
    cell.planUserIconImageView.layer.cornerRadius = 40 * 0.5
    cell.planUserIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TimelineViewController.userImageViewTapped(_:))))
    cell.planUserIconImageView.isUserInteractionEnabled = true
    print(cell.planUserIconImageView.frame.width)
    cell.planUserIconImageView.clipsToBounds = true
    cell.planUserNameLabel.text = userNameList[indexPath.row]
    self.ActivityIndicator.stopAnimating()
    planCount = indexPath.row + 1
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //tableView.deselectRow(at: indexPath, animated: true)
    self.performSegue(withIdentifier: "toDetailPlanView", sender: planIdList[indexPath.row])
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "toDetailPlanView"){
      print("プランIdは")
      print(sender as! Int)
      print("プランIdは")
      let nextViewController = segue.destination as! DatailPlanViewController
      nextViewController.planId = sender as! Int
    }else if(segue.identifier == "toDetailUserView"){
      let nextViewController = segue.destination as! DetailUserViewController
      nextViewController.editFlag = false
    }
  }
  
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
//      self.getPlan(offset: self.planCount)
      self.tableView.reloadData()
      sender.endRefreshing()
    })
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (self.tableView.contentOffset.y + self.tableView.frame.size.height > self.tableView.contentSize.height && self.tableView.isDragging && isaddload == true){
      self.isaddload = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        for _ in 0..<0{
          self.sampledatas.append(self.sampledatas.last! + 1)
//          self.getPlan(offset: self.planCount)
        }
        if(self.sampledatas.count > 50){
          self.isaddload = false
          self.tableView.tableFooterView = UIView()
        }else{
          self.isaddload = true
        }
        self.tableView.reloadData()
      }
    }
  }
  

  
//  struct PlanData : Codable{
//    let status : Int
//    let record : [Record]?
//    let message : String?
//    enum CodingKeys: String, CodingKey {
//      case status
//      case record
//      case message
//    }
//    struct Record : Codable{
//      let planId : Int
//      let userId : String
//      let planTitle : String
//      let planComment : String?
//      let transportation : String?
//      let price : String?
//      let area : String?
//      let spotIdA : Int?
//      let spotIdB : Int?
//      let spotIdC : Int?
//      let spotIdD : Int?
//      let spotIdE : Int?
//      let spotIdF : Int?
//      let spotIdG : Int?
//      let spotIdH : Int?
//      let spotIdI : Int?
//      let spotIdJ : Int?
//      let spotIdK : Int?
//      let spotIdL : Int?
//      let spotIdM : Int?
//      let spotIdN : Int?
//      let spotIdO : Int?
//      let spotIdP : Int?
//      let spotIdQ : Int?
//      let spotIdR : Int?
//      let spotIdS : Int?
//      let spotIdT : Int?
////      let planDate : String
//      let date : Date? = NSDate() as Date
//      enum CodingKeys: String, CodingKey {
//        case planId = "plan_id"
//        case userId = "user_id"
//        case planTitle = "plan_title"
//        case planComment = "spot_comment"
//        case transportation = "transportation"
//        case price = "price"
//        case area = "area"
//        case spotIdA = "spot_id_a"
//        case spotIdB = "spot_id_b"
//        case spotIdC = "spot_id_c"
//        case spotIdD = "spot_id_d"
//        case spotIdE = "spot_id_e"
//        case spotIdF = "spot_id_f"
//        case spotIdG = "spot_id_g"
//        case spotIdH = "spot_id_h"
//        case spotIdI = "spot_id_i"
//        case spotIdJ = "spot_id_j"
//        case spotIdK = "spot_id_k"
//        case spotIdL = "spot_id_l"
//        case spotIdM = "spot_id_m"
//        case spotIdN = "spot_id_n"
//        case spotIdO = "spot_id_o"
//        case spotIdP = "spot_id_p"
//        case spotIdQ = "spot_id_q"
//        case spotIdR = "spot_id_r"
//        case spotIdS = "spot_id_s"
//        case spotIdT = "spot_id_t"
////        case planDate = "plan_date"
//        case date
//      }
//    }
//  }
//  struct UserData : Codable{
//    let status : Int
//    let record : [Record]?
//    let message : String?
//    enum CodingKeys: String, CodingKey {
//      case status
//      case record
//      case message
//    }
//    struct Record : Codable{
//      let userId : String
//      let userName : String
//      let generation : Int
//      let gender : String
//      let comment : String?
//      let userIcon : String?
//      let userHeader : String?
//      let date : Date? = NSDate() as Date
//      enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//        case userName = "user_name"
//        case generation = "generation"
//        case gender = "gender"
//        case comment = "comment"
//        case userIcon = "user_icon"
//        case userHeader = "user_header"
//        case date
//      }
//    }
//  }
//  struct SpotData : Codable{
//    let status : Int
//    let record : [Record]?
//    let message : String?
//    enum CodingKeys: String, CodingKey {
//      case status
//      case record
//      case message
//    }
//    struct Record : Codable{
//      let spotId : Int
//      let userId : String
//      let spotTitle : String
//      let spotAddress : SpotAddress
//      let spotComment : String?
//      let spotImageA : String?
//      let spotImageB : String?
//      let spotImageC : String?
//      let date : Date? = NSDate() as Date
//      enum CodingKeys: String, CodingKey {
//        case spotId = "spot_id"
//        case userId = "user_id"
//        case spotTitle = "spot_title"
//        case spotAddress = "spot_address"
//        case spotComment = "spot_comment"
//        case spotImageA = "spot_image_a"
//        case spotImageB = "spot_image_b"
//        case spotImageC = "spot_image_c"
//        case date = "date"
//      }
//      struct SpotAddress : Codable{
//        let x : Double
//        let y : Double
//        enum CodingKeys: String, CodingKey {
//          case x = "lat"
//          case y = "lng"
//        }
//      }
//    }
//  }
  struct TimelineData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let planId : Int
      let userId : String
      let planTitle : String
      let planComment : String?
      let transportation : String
      let price : String
      let area : String
      let planDate : String
      let user : User
      let spots : [Spots]
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case userId = "user_id"
        case planTitle = "plan_title"
        case planComment = "plan_comment"
        case transportation = "transportation"
        case price = "price"
        case area = "area"
        case planDate = "plan_date"
        case user = "user"
        case spots = "spots"
        case date
      }
      struct User : Codable{
        let userName : String
        let userIcon : String
        enum CodingKeys: String, CodingKey {
          case userName = "user_name"
          case userIcon = "user_icon"
        }
      }
      struct Spots : Codable{
        let spotId : Int
        let spotTitle : String
        let spotImageA : String?
        let spotImageB : String?
        let spotImageC : String?
        enum CodingKeys: String, CodingKey {
          case spotId = "spot_id"
          case spotTitle = "spot_title"
          case spotImageA = "spot_image_a"
          case spotImageB = "spot_image_b"
          case spotImageC = "spot_image_c"
        }
      }
    }
  }
  
  func getTimeline(offset:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let timelineData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(timelineData!.status == 200){
          for i in 0...0{
            var count = 0
            self.planIdList.append((timelineData?.record![i].planId)!)
            self.userIdList.append((timelineData?.record![i].userId)!)
            self.planTitleList.append((timelineData?.record![i].planTitle)!)
            self.userNameList.append((timelineData?.record![i].user.userName)!)
            let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
            let imageData = try? Data(contentsOf: url)
            let image = UIImage(data:imageData!)
            self.userImageList.append(image!)
            let planDate = (timelineData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.dateList.append("\(date)日")
            for f in 0 ... (timelineData?.record![i].spots.count)! - 1{
              if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                self.spotImagePathList?.append((timelineData?.record![i].spots[f].spotImageA)!)
              }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                self.spotImagePathList?.append((timelineData?.record![i].spots[f].spotImageB)!)
              }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                self.spotImagePathList?.append((timelineData?.record![i].spots[f].spotImageC)!)
              }
              if(f == 0){
                self.spotNameListA.append((timelineData?.record![i].spots[f].spotTitle)!)
                self.spotNameListB?.append("nil")
              }else if(f == 1){
                self.spotNameListB?[i] = (timelineData?.record![i].spots[f].spotTitle)!
              }else{
                count += 1
              }
            }
            self.spotImagePathList?.append("")
            self.spotCountList.append(count)
            self.trueSpotImagePathList?.append(self.spotImagePathList![i])
            if(self.trueSpotImagePathList![i] != ""){
              let url = URL(string: self.trueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.spotImageList?.append(image!)
            }else{
              self.spotImageList?.append(UIImage(named: "no-image.png")!)
            }
            self.spotImagePathList?.removeAll()
          }
          self.tableView.reloadData()
        }else{
          print("status",timelineData!.status)
        }
      }
    }.resume()
  }
  
  func getPlan(offset:Int){
//
//    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)")
//    let request = URLRequest(url: url!)
//    let session = URLSession.shared
//    session.dataTask(with: request) { (data, response, error) in
//      if error == nil, let data = data, let response = response as? HTTPURLResponse {
//        // HTTPヘッダの取得
//        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
//        // HTTPステータスコード
//        print("statusCode: \(response.statusCode)")
//        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
//        let planData = try? JSONDecoder().decode(PlanData.self, from: data)
//        if(planData!.status == 200){
//          for i in 0...9{
//            self.planIdList.append(planData!.record![i].planId)
//            self.planTitleList.append(planData!.record![i].planTitle)
//            self.userIdList.append(planData!.record![i].userId)
//
//            var strDate = "2018-12-03T16:21:55"
//            for _ in 0...9{
//              if let range = strDate.range(of: "-") {
//                strDate.replaceSubrange(range, with: "/")
//                print("日付:",strDate)
//              }
//            }
//            let prefixDate = strDate.prefix(11)
//            var suffixDate = prefixDate.suffix(6)
//            if let range = suffixDate.range(of: "/") {
//              suffixDate.replaceSubrange(range, with: "月")
//              print("日付:",suffixDate)
//            }
//            if let range = suffixDate.range(of: "T") {
//              suffixDate.replaceSubrange(range, with: "日")
//              print("日付:",suffixDate)
//            }
//            self.spotImagePathList?.append("no-image")
//            self.spotImageList?.append(UIImage(named: "no-image.png")!)
//            self.userImageList.append(UIImage(named: "no-image.png")!)
////            print("日付",planData!.record![i].planDate)
//            self.dateList.append(String(suffixDate))
//            self.getUserImage(userId: self.userIdList[i], number: i)
//            self.spotImageSetFlag.append(0)
//            var count = 0
//            self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "A", number: i)
//            print("プランID",self.planIdList[i])
//            if(planData!.record![i].spotIdB != nil){
//              self.getSpot(spotId: (planData?.record![i].spotIdB)!, flag: self.spotImageSetFlag[i], spot: "B", number: i)
//              if(planData!.record![i].spotIdC != nil){
//                count += 1
//                if(self.spotImageSetFlag[i] == 0){
//                  self.getSpot(spotId: (planData?.record![i].spotIdC)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                }
//                if(planData!.record![i].spotIdD != nil){
//                  count += 1
//                  if(self.spotImageSetFlag[i] == 0){
//                    self.getSpot(spotId: (planData?.record![i].spotIdD)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                  }
//                  if(planData!.record![i].spotIdE != nil){
//                    count += 1
//                    if(self.spotImageSetFlag[i] == 0){
//                      self.getSpot(spotId: (planData?.record![i].spotIdE)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                    }
//                    if(planData!.record![i].spotIdF != nil){
//                      count += 1
//                      if(self.spotImageSetFlag[i] == 0){
//                        self.getSpot(spotId: (planData?.record![i].spotIdF)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                      }
//                      if(planData!.record![i].spotIdG != nil){
//                        count += 1
//                        if(self.spotImageSetFlag[i] == 0){
//                          self.getSpot(spotId: (planData?.record![i].spotIdG)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                        }
//                        if(planData!.record![i].spotIdH != nil){
//                          count += 1
//                          if(self.spotImageSetFlag[i] == 0){
//                            self.getSpot(spotId: (planData?.record![i].spotIdH)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                          }
//                          if(planData!.record![i].spotIdI != nil){
//                            count += 1
//                            if(self.spotImageSetFlag[i] == 0){
//                              self.getSpot(spotId: (planData?.record![i].spotIdI)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                            }
//                            if(planData!.record![i].spotIdJ != nil){
//                              count += 1
//                              if(self.spotImageSetFlag[i] == 0){
//                                self.getSpot(spotId: (planData?.record![i].spotIdJ)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                              }
//                              if(planData!.record![i].spotIdK != nil){
//                                count += 1
//                                if(self.spotImageSetFlag[i] == 0){
//                                  self.getSpot(spotId: (planData?.record![i].spotIdK)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                }
//                                if(planData!.record![i].spotIdL != nil){
//                                  count += 1
//                                  if(self.spotImageSetFlag[i] == 0){
//                                    self.getSpot(spotId: (planData?.record![i].spotIdL)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                  }
//                                  if(planData!.record![i].spotIdM != nil){
//                                    count += 1
//                                    if(self.spotImageSetFlag[i] == 0){
//                                      self.getSpot(spotId: (planData?.record![i].spotIdM)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                    }
//                                    if(planData!.record![i].spotIdN != nil){
//                                      count += 1
//                                      if(self.spotImageSetFlag[i] == 0){
//                                        self.getSpot(spotId: (planData?.record![i].spotIdN)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                      }
//                                      if(planData!.record![i].spotIdO != nil){
//                                        count += 1
//                                        if(self.spotImageSetFlag[i] == 0){
//                                          self.getSpot(spotId: (planData?.record![i].spotIdO)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                        }
//                                        if(planData!.record![i].spotIdP != nil){
//                                          count += 1
//                                          if(self.spotImageSetFlag[i] == 0){
//                                            self.getSpot(spotId: (planData?.record![i].spotIdP)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                          }
//                                          if(planData!.record![i].spotIdQ != nil){
//                                            count += 1
//                                            if(self.spotImageSetFlag[i] == 0){
//                                              self.getSpot(spotId: (planData?.record![i].spotIdQ)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                            }
//                                            if(planData!.record![i].spotIdR != nil){
//                                              count += 1
//                                              if(self.spotImageSetFlag[i] == 0){
//                                                self.getSpot(spotId: (planData?.record![i].spotIdR)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                              }
//                                              if(planData!.record![i].spotIdS != nil){
//                                                count += 1
//                                                if(self.spotImageSetFlag[i] == 0){
//                                                  self.getSpot(spotId: (planData?.record![i].spotIdS)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                                }
//                                                if(planData!.record![i].spotIdT != nil){
//                                                  count += 1
//                                                  if(self.spotImageSetFlag[i] == 0){
//                                                    self.getSpot(spotId: (planData?.record![i].spotIdT)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
//                                                  }
//                                                }
//                                              }
//                                            }
//                                          }
//                                        }
//                                      }
//                                    }
//                                  }
//                                }
//                              }
//                            }
//                          }
//                        }
//                      }
//                    }
//                  }
//                }
//              }
//            }else{
//              self.spotNameListB?.append("nil")
//            }
//            self.spotCountList.append(count)
//          }
//        }
//      }
//    }.resume()
  }
  func getUserImage(userId:String,number :Int){
//    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/find?user_id=\(userId)")
//    let request = URLRequest(url: url!)
//    let session = URLSession.shared
//    session.dataTask(with: request) { (data, response, error) in
//      if error == nil, let data = data, let response = response as? HTTPURLResponse {
//        // HTTPヘッダの取得
//        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
//        // HTTPステータスコード
//        print("statusCode: \(response.statusCode)")
//        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
//        let userData = try? JSONDecoder().decode(UserData.self, from: data)
//        if(userData!.status == 200){
//          self.userImagePathList.append((userData?.record![0].userIcon)!)
//          print(self.userImagePathList[0])
////          self.userImageList[number] = (userData?.record![0].userIcon)!
//          let url = URL(string: (userData?.record![0].userIcon)!)!
//          let imageData = try? Data(contentsOf: url)
//          let image = UIImage(data:imageData!)
//          self.userImageList[number] = image!
//          self.userNameList.append((userData?.record![0].userName)!)
//        }
//      }
//    }.resume()
  }
  
  func getSpot(spotId:Int, flag:Int, spot:String, number:Int){
//    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/spot/find?spot_id=\(spotId)")
//    let request = URLRequest(url: url!)
//    let session = URLSession.shared
//    session.dataTask(with: request) { (data, response, error) in
//      if error == nil, let data = data, let response = response as? HTTPURLResponse {
//        // HTTPヘッダの取得
//        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
//        // HTTPステータスコード
//        print("statusCode: \(response.statusCode)")
//        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
//        let spotData = try! JSONDecoder().decode(SpotData.self, from: data)
//        if (spotData.status == 200){
//          if(spot == "A"){
//            self.spotNameListA.append(spotData.record![0].spotTitle)
//            if(spotData.record![0].spotImageA != nil && spotData.record![0].spotImageA != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageA!
//              let url = URL(string: spotData.record![0].spotImageA!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }else if(spotData.record![0].spotImageB != nil && spotData.record![0].spotImageB != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageB!
//              let url = URL(string: spotData.record![0].spotImageB!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//              self.spotImagePathList?.append(spotData.record![0].spotImageB!)
//            }else if(spotData.record![0].spotImageC != nil && spotData.record![0].spotImageC != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageC!
//              let url = URL(string: spotData.record![0].spotImageC!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }
//          }else if(spot == "B"){
//            self.spotNameListB?.append(spotData.record![0].spotTitle)
//            if(spotData.record![0].spotImageA != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageA != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageA!
//              let url = URL(string: spotData.record![0].spotImageA!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }else if(spotData.record![0].spotImageB != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageB != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageB!
//              let url = URL(string: spotData.record![0].spotImageB!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }else if(spotData.record![0].spotImageC != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageC != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageC!
//              let url = URL(string: spotData.record![0].spotImageC!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }
//          }else{
//            if(spotData.record![0].spotImageA != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageA != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageA!
//              let url = URL(string: spotData.record![0].spotImageA!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }else if(spotData.record![0].spotImageB != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageB != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageB!
//              let url = URL(string: spotData.record![0].spotImageB!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }else if(spotData.record![0].spotImageC != nil && self.spotImageSetFlag[number] == 0 && spotData.record![0].spotImageC != ""){
//              self.spotImageSetFlag[number] = 1
//              self.spotImagePathList![number] = spotData.record![0].spotImageC!
//              let url = URL(string: spotData.record![0].spotImageC!)!
//              let imageData = try? Data(contentsOf: url)
//              let image = UIImage(data:imageData!)
//              self.spotImageList![number] = image!
//            }
//          }
//          print("画像",self.spotImagePathList!)
//          print("A",self.spotNameListA)
//          print("B",self.spotNameListB!)
//          if(number == 9){
//            self.tableView.reloadData()
//          }
//        }
//      }
//    }.resume()
  }
  
  @objc func userImageViewTapped(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
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
}

extension UITableView {
  func register<T: UITableViewCell>(cellType: T.Type) {
    let className = cellType.className
    let nib = UINib(nibName: className, bundle: nil)
    register(nib, forCellReuseIdentifier: className)
  }
  
  func register<T: UITableViewCell>(cellTypes: [T.Type]) {
    cellTypes.forEach { register(cellType: $0) }
  }
  
  func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
    return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
  }
}

extension NSObject{
  class var className: String {
    return String(describing: self)
  }
  
  var className: String {
    return type(of: self).className
  }
}
