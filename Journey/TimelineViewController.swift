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
  var spotIdList : [Int] = []
  var spotNameListA : [String] = []
  var spotNameListB : [String]? = []
  var spotImagePathList : [String]? = []
  var trueSpotImagePathList : [String]? = []
  var spotImageList : [UIImage]? = []
  var userImageList : [UIImage] = []
  var planAreaList : [String] = []
  var planTransportationList : [String] = []
  var planPriceList : [String] = []
  var planCommentList : [String] = []
  var planCount = 0
  var reloadFlag = 0
  var area : String = ""
  //受け渡し用
  var planId = 0
  var planTitle = ""
  var userId = ""
  var userImage = UIImage()
  var userName = ""
  var planArea = ""
  var planTransportation = ""
  var planPrice = ""
  var planComment = ""
  var spotCountList2 : [Int] = []
  var spotIdList2 : [Int] = []
  
  //SearchViewから受け取る値
  var searchText = ""
  var searchTransportationString = ""
  var searchPrice = ""
  var searchArea = ""
  var searchGeneration = ""
  var searchFlag = 0
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createTabBar()
    self.navigationItem.hidesBackButton = true
    print(searchTransportationString)
    print(searchPrice)
    print(searchGeneration)
    if(searchFlag == 0){
      getTimeline(offset: planCount,flag: 0, area: area)
    }else if(searchFlag == 1){
      if(searchTransportationString == "0,0,0,0,0,0,0"){
        searchTransportationString = ""
      }
      searchTimeline(offset: planCount, flag: 0, area: searchArea, transportation: searchTransportationString, praice: searchPrice, text: searchText, generation: searchGeneration)
    }
//    tableView.reloadData()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    tableView.register(cellType: LoaddingTableViewCell.self)
    let footerCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoaddingTableViewCell")!
    //(footerCell as! LoaddingTableViewCell).startAnimationg()
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
    if(reloadFlag == 1){
      print(spotNameListB!)
      print(spotCountList)
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
    }
    print("reloadFlag",reloadFlag)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    planId = planIdList[indexPath.row]
    planTitle = planTitleList[indexPath.row]
    planArea = planAreaList[indexPath.row]
    planComment = planCommentList[indexPath.row]
    planTransportation = planTransportationList[indexPath.row]
    planPrice = planPriceList[indexPath.row]
    userId = userIdList[indexPath.row]
    userImage = userImageList[indexPath.row]
    userName = userNameList[indexPath.row]
    var spotCount = 0
    for i in 0 ..< indexPath.row {
      if(spotCountList[i] == 0){
        if(spotNameListB![i] == "nil"){//
          spotCount += 1
        }else{
          spotCount += 2
        }
      }else{
        spotCount += spotCountList[i] + 2
      }
    }
    
    var spotLoop = 0
    if(spotCountList[indexPath.row] == 0){
      if(spotNameListB![indexPath.row] != "nil"){//
        spotLoop = 1
      }
    }else{
      spotLoop += spotCountList[indexPath.row] + 1
    }
    
    for i in 0 ... spotLoop {
      spotIdList2.append(spotIdList[spotCount])
      print("indexパス：",indexPath.row)
      print("スポットCount：",spotCount)
      print("スポットid：",spotIdList2[i])
      spotCount += 1
    }
    self.performSegue(withIdentifier: "toDetailPlanView", sender: planIdList[indexPath.row])
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "toDetailPlanView"){
      let nextViewController = segue.destination as! DatailPlanViewController
      nextViewController.planId = planId
      nextViewController.userId = userId
      nextViewController.userName = userName
      nextViewController.userImage = userImage
      nextViewController.planTitle = planTitle
      nextViewController.planArea = planArea
      nextViewController.planTransportationString = planTransportation
      nextViewController.planComment = planComment
      nextViewController.planPrice = planPrice
      nextViewController.spotIdList = spotIdList2
      spotIdList2.removeAll()
      
    }else if(segue.identifier == "toDetailUserView"){
      let nextViewController = segue.destination as! DetailUserViewController
      nextViewController.editFlag = false
    }
  }
  
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      //上スクロール
      if(self.searchFlag == 0){
        self.getTimeline(offset: self.planCount,flag: 1, area: self.area)
      }else if(self.searchFlag == 1){
        if(self.searchTransportationString == "0,0,0,0,0,0,0"){
          self.searchTransportationString = ""
        }
        self.searchTimeline(offset: self.planCount, flag: 1, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.searchGeneration)
      }
//      self.tableView.reloadData()
      sender.endRefreshing()
    })
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (self.tableView.contentOffset.y + self.tableView.frame.size.height > self.tableView.contentSize.height && self.tableView.isDragging && isaddload == true){
      self.isaddload = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if(self.searchFlag == 0){
          self.getTimeline(offset: self.planCount,flag: 0, area: self.area)
        }else if(self.searchFlag == 1){
          if(self.searchTransportationString == "0,0,0,0,0,0,0"){
            self.searchTransportationString = ""
          }
          self.searchTimeline(offset: self.planCount, flag: 0, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.searchGeneration)
        }
        if(self.sampledatas.count > 50){
          self.isaddload = false
          self.tableView.tableFooterView = UIView()
        }else{
          self.isaddload = true
        }
//        self.tableView.reloadData()
      }
    }
  }
  
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
  
  func getTimeline(offset:Int,flag:Int,area:String){
    var text = "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)&\(area)"
    text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
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
        let timelineData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(timelineData!.status == 200){
          if(flag == 1){
            let planId = self.planIdList[0]
            for_plan: for i in 0 ... (timelineData?.record?.count)! - 1{
              if(timelineData?.record![i].planId != planId){
                var count = 0
                self.planIdList.insert((timelineData?.record![i].planId)!, at: i)
                self.userIdList.insert((timelineData?.record![i].userId)!, at: i)
                self.planTitleList.insert((timelineData?.record![i].planTitle)!, at: i)
                self.userNameList.insert((timelineData?.record![i].user.userName)!, at: i)
                self.planAreaList.insert((timelineData?.record![i].area)!, at: i)
                self.planTransportationList.insert((timelineData?.record![i].transportation)!, at: i)
                self.planPriceList.insert((timelineData?.record![i].price)!, at: i)
                self.planCommentList.insert((timelineData?.record![i].planComment)!, at: i)
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
                  self.spotIdList.insert((timelineData?.record![i].spots[f].spotId)!, at: i)
                  if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageA)!, at: i)
                  }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageB)!, at: i)
                  }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageC)!, at: i)
                  }
                  if(f == 0){
                    self.spotNameListA.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                    self.spotNameListB?.insert("nil", at: offset + i)
                  }else if(f == 1){
                    self.spotNameListB?[offset + i] = (timelineData?.record![i].spots[f].spotTitle)!
                  }else{
                    count += 1
                  }
                }
                self.spotImagePathList?.append("")
                self.spotCountList.insert(count, at: i)
                self.trueSpotImagePathList?.append(self.spotImagePathList![0])
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.insert(image!, at: i)
                }else{
                  self.spotImageList?.insert(UIImage(named: "no-image.png")!, at: i)
                }
                self.spotImagePathList?.removeAll()
              }else{
                break for_plan
              }
            }
          }else{
            for i in 0 ... (timelineData?.record?.count)! - 1{
              var count = 0
              self.planIdList.append((timelineData?.record![i].planId)!)
              self.userIdList.append((timelineData?.record![i].userId)!)
              self.planTitleList.append((timelineData?.record![i].planTitle)!)
              self.userNameList.append((timelineData?.record![i].user.userName)!)
              self.planAreaList.append((timelineData?.record![i].area)!)
              self.planTransportationList.append((timelineData?.record![i].transportation)!)
              self.planPriceList.append((timelineData?.record![i].price)!)
              self.planCommentList.append((timelineData?.record![i].planComment)!)
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
                self.spotIdList.append((timelineData?.record![i].spots[f].spotId)!)
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
                  self.spotNameListB?[offset + i] = (timelineData?.record![i].spots[f].spotTitle)!
                }else{
                  count += 1
                }
              }
              self.spotImagePathList?.append("")
              self.spotCountList.append(count)
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(self.trueSpotImagePathList![i] != ""){
                let url = URL(string: self.trueSpotImagePathList![i])!
                let imageData = try? Data(contentsOf: url)
                let image = UIImage(data:imageData!)
                self.spotImageList?.append(image!)
              }else{
                self.spotImageList?.append(UIImage(named: "no-image.png")!)
              }
              self.spotImagePathList?.removeAll()
              self.planCount += 1
            }
          }
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print("リロードテーブル")
            self.reloadFlag = 1
            self.tableView.reloadData()
          }
        }else{
          print("status",timelineData!.status)
        }
      }
    }.resume()
  }
  
  func searchTimeline(offset:Int,flag:Int,area:String,transportation:String,praice:String,text:String,generation:String){
    var text = "http://\(globalVar.ipAddress)/api/v1/search/find?keyword=\(text)&generation=\(generation)&area=\(area)&price=\(praice)&transportation=\(transportation)&offset=\(offset)"
    text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
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
        let timelineData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(timelineData!.status == 200){
          if(flag == 1){
            let planId = self.planIdList[0]
            for_plan: for i in 0 ... (timelineData?.record?.count)! - 1{
              if(timelineData?.record![i].planId != planId){
                var count = 0
                self.planIdList.insert((timelineData?.record![i].planId)!, at: i)
                self.userIdList.insert((timelineData?.record![i].userId)!, at: i)
                self.planTitleList.insert((timelineData?.record![i].planTitle)!, at: i)
                self.userNameList.insert((timelineData?.record![i].user.userName)!, at: i)
                self.planAreaList.insert((timelineData?.record![i].area)!, at: i)
                self.planTransportationList.insert((timelineData?.record![i].transportation)!, at: i)
                self.planPriceList.insert((timelineData?.record![i].price)!, at: i)
                self.planCommentList.insert((timelineData?.record![i].planComment)!, at: i)
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
                  self.spotIdList.insert((timelineData?.record![i].spots[f].spotId)!, at: i)
                  if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageA)!, at: i)
                  }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageB)!, at: i)
                  }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                    self.spotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageC)!, at: i)
                  }
                  if(f == 0){
                    self.spotNameListA.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                    self.spotNameListB?.insert("nil", at: offset + i)
                  }else if(f == 1){
                    self.spotNameListB?[offset + i] = (timelineData?.record![i].spots[f].spotTitle)!
                  }else{
                    count += 1
                  }
                }
                self.spotImagePathList?.append("")
                self.spotCountList.insert(count, at: i)
                self.trueSpotImagePathList?.append(self.spotImagePathList![0])
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.insert(image!, at: i)
                }else{
                  self.spotImageList?.insert(UIImage(named: "no-image.png")!, at: i)
                }
                self.spotImagePathList?.removeAll()
              }else{
                break for_plan
              }
            }
          }else{
            for i in 0 ... (timelineData?.record?.count)! - 1{
              var count = 0
              self.planIdList.append((timelineData?.record![i].planId)!)
              self.userIdList.append((timelineData?.record![i].userId)!)
              self.planTitleList.append((timelineData?.record![i].planTitle)!)
              self.userNameList.append((timelineData?.record![i].user.userName)!)
              self.planAreaList.append((timelineData?.record![i].area)!)
              self.planTransportationList.append((timelineData?.record![i].transportation)!)
              self.planPriceList.append((timelineData?.record![i].price)!)
              self.planCommentList.append((timelineData?.record![i].planComment)!)
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
                self.spotIdList.append((timelineData?.record![i].spots[f].spotId)!)
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
                  self.spotNameListB?[offset + i] = (timelineData?.record![i].spots[f].spotTitle)!
                }else{
                  count += 1
                }
              }
              self.spotImagePathList?.append("")
              self.spotCountList.append(count)
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(self.trueSpotImagePathList![i] != ""){
                let url = URL(string: self.trueSpotImagePathList![i])!
                let imageData = try? Data(contentsOf: url)
                let image = UIImage(data:imageData!)
                self.spotImageList?.append(image!)
              }else{
                self.spotImageList?.append(UIImage(named: "no-image.png")!)
              }
              self.spotImagePathList?.removeAll()
              self.planCount += 1
            }
          }
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            print("リロードテーブル")
            self.reloadFlag = 1
            self.tableView.reloadData()
          }
        }else{
          self.showAlert(title: "該当する結果がありません", message: "検索をやり直してください")
        }
      }
      }.resume()
  }
  func showAlert(title:String,message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
      //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // 0.5秒後に実行したい処理
        self.performSegue(withIdentifier: "toSearchView", sender: nil)
      }
    }
    )
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
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
      performSegue(withIdentifier: "toStartView", sender: nil)
    case 2:
      performSegue(withIdentifier: "toSearchView", sender: nil)    case 3:
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
