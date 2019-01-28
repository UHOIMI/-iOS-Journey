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

  @IBOutlet weak var userBarButtonItem: UIBarButtonItem!
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
  var planFavoriteCountList : [Int] = []
  var planCount = 0
  var reloadFlag = 0
  var area : String = ""
  var nextDetailUserId = ""
  var userEditFlag = false
  var firstSearchFlag = true
  
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
  
  //SearchViewから受け取る値
  var searchText = ""
  var searchTransportationString = ""
  var searchPrice = ""
  var searchArea = ""
  var searchGeneration = ""
  var searchFlag = 0
  var generation = 110
  
  //DetailUserから受け取る
  var detailUserFlag = 0
  var detailUserId = ""
  
  //FavoriteButtonから遷移
  var favoriteFlag = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createTabBar()
    
    let leftButton: UIButton = UIButton()
    leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    leftButton.setImage(globalVar.userIcon, for: UIControl.State.normal)
    leftButton.imageView?.layer.cornerRadius = 40 * 0.5
    leftButton.imageView?.clipsToBounds = true
    leftButton.addTarget(self, action: #selector(TimelineViewController.userIconTapped(sender:)), for: .touchUpInside)
    userBarButtonItem.customView = leftButton
    userBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
    userBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
    
    self.navigationItem.hidesBackButton = true
    print(searchTransportationString)
    print(searchPrice)
    print(searchGeneration)
    if(favoriteFlag == 1){
      favoriteTimeline(userId: globalVar.userId, offset: 0, flag: 0)
    }else if(detailUserFlag == 1){
      navigationItem.title = "過去のプラン一覧"
      getUserTimeline(offset: planCount, flag: 0, userId: detailUserId)
    }else if(searchFlag == 0){
      navigationItem.title = "新着プラン一覧"
      getTimeline(offset: planCount,flag: 0, area: area)
    }else if(searchFlag == 1){
      navigationItem.title = "検索結果一覧"
      if(searchTransportationString == "0,0,0,0,0,0,0"){
        searchTransportationString = ""
      }
      if(searchGeneration != ""){
        switch searchGeneration {
        case "10歳未満":
          generation = 0
          break
        case "10代":
          generation = 10
          break
        case "20代":
          generation = 20
          break
        case "30代":
          generation = 30
          break
        case "40代":
          generation = 40
          break
        case "50代":
          generation = 50
          break
        case "60代":
          generation = 60
          break
        case "70代":
          generation = 70
          break
        case "80代":
          generation = 80
          break
        case "90代":
          generation = 90
          break
        case "100歳以上":
          generation = 100
          break
        default:
          break
        }
        searchGenerationTimelin(offset: planCount, flag: 0, area: searchArea, transportation: searchTransportationString, praice: searchPrice, text: searchText, generation: generation)
      }else{
        searchTimeline(offset: planCount, flag: 0, area: searchArea, transportation: searchTransportationString, praice: searchPrice, text: searchText, generation: searchGeneration)
      }
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
      cell.isUserInteractionEnabled = true
      cell.planNameLabel.text =  planTitleList[indexPath.row]
      cell.planSpotNameLabel1.text = spotNameListA[indexPath.row]
      cell.planSpotNameLabel2.text = spotNameListB?[indexPath.row]
      if(spotCountList[indexPath.row] == 0){
        cell.otherSpotLabel.text = ""
      }else{
        cell.otherSpotLabel.text = "他\(spotCountList[indexPath.row])件"
      }
      cell.planFavoriteLabel.text = "\(planFavoriteCountList[indexPath.row])"
      print("画像パス",indexPath.row)
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
      print("交通手段", planTransportation)
      print("交通手段2", planTransportationList)
      nextViewController.planTransportationString = planTransportation
      nextViewController.planComment = planComment
      nextViewController.planPrice = planPrice
      
    }else if(segue.identifier == "toDetailUserView"){
      let nextViewController = segue.destination as! DetailUserViewController
      if(userEditFlag){
        nextViewController.editFlag = true
      }else{
        nextViewController.editFlag = userEditFlag
        nextViewController.userId = nextDetailUserId
      }
    }
  }
  
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      //上スクロール
      if(self.favoriteFlag == 1){
        self.favoriteTimeline(userId: self.globalVar.userId, offset: self.planCount, flag: 1)
      }else if(self.detailUserFlag == 1){
        self.getUserTimeline(offset: self.planCount, flag: 1, userId: self.detailUserId)
      }else if(self.searchFlag == 0){
        self.getTimeline(offset: self.planCount,flag: 1, area: self.area)
      }else if(self.searchFlag == 1){
        if(self.searchTransportationString == "0,0,0,0,0,0,0"){
          self.searchTransportationString = ""
        }
        if(self.generation != 110){
          self.searchGenerationTimelin(offset: self.planCount, flag: 1, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.generation)
        }else{
          self.searchTimeline(offset: self.planCount, flag: 1, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.searchGeneration)
        }
      }
//      self.tableView.reloadData()
      sender.endRefreshing()
    })
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (self.tableView.contentOffset.y + self.tableView.frame.size.height > self.tableView.contentSize.height && self.tableView.isDragging && isaddload == true){
          self.isaddload = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        if(self.favoriteFlag == 1){
          self.favoriteTimeline(userId: self.globalVar.userId, offset: self.planCount, flag: 0)
        }else if(self.detailUserFlag == 1){
          self.getUserTimeline(offset: self.planCount, flag: 0, userId: self.detailUserId)
        }else if(self.searchFlag == 0){
          self.getTimeline(offset: self.planCount,flag: 0, area: self.area)
        }else if(self.searchFlag == 1){
          if(self.searchTransportationString == "0,0,0,0,0,0,0"){
            self.searchTransportationString = ""
          }
          if(self.generation != 110){
            self.searchGenerationTimelin(offset: self.planCount, flag: 0, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.generation)
          }else{
          self.searchTimeline(offset: self.planCount, flag: 0, area: self.searchArea, transportation: self.searchTransportationString, praice: self.searchPrice, text: self.searchText, generation: self.searchGeneration)
          }
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
        let userIcon : String?
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
    var text = "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)&area=\(area)&limit=10"
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
          self.firstSearchFlag = false
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
                self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 1, number: i)
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
                
                for f in 0 ... (timelineData?.record![0].spots.count)! - 1{
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
                  }else if(f == 1){
                    self.spotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                  }else if(f > 1){
                    count += 1
                  }
                }
                self.spotCountList.insert(count, at: i)
                self.spotImagePathList?.append("")
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
              self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 0, number: i)
              if(timelineData?.record![i].user.userIcon != ""){
                let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
                let imageData = try? Data(contentsOf: url)
                let image = UIImage(data:imageData!)
                self.userImageList.append(image!)
              }else{
                self.userImageList.append(UIImage(named: "no-image.png")!)
              }
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
                  self.spotNameListB?.append("")
                }else if(f == 1){
                  self.spotNameListB!.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                }else if(f > 1){
                  count += 1
                }
              }
              self.spotCountList.append(count)
              self.spotImagePathList?.append("")
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(offset == 0){
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }else{
                if(self.trueSpotImagePathList![i + offset - 1] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i + offset - 1])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
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
  
  func searchGenerationTimelin(offset:Int,flag:Int,area:String,transportation:String,praice:String,text:String,generation:Int){
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
          self.firstSearchFlag = false
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
                self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 1, number: i)
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
                  }else if(f == 1){
                    self.spotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                  }else if(f > 1){
                    count += 1
                  }
                }
                self.spotCountList.insert(count, at: i)
                self.spotImagePathList?.append("")
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
              self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 0, number: i)
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
                  self.spotNameListB?.append("")
                }else if(f == 1){
                  self.spotNameListB!.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                }else if(f > 1){
                  count += 1
                }
              }
              self.spotCountList.append(count)
              self.spotImagePathList?.append("")
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(offset == 0){
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }else{
                if(self.trueSpotImagePathList![i + offset - 1] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i + offset - 1])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
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
          if(!self.firstSearchFlag){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
              self.tableView.tableFooterView?.isHidden = true
              self.tableView.tableFooterView = nil
            }
          }else{
            self.showAlert(title: "該当する結果がありません", message: "検索をやり直してください")
          }
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
          self.firstSearchFlag = false
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
                self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 1, number: i)
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
                  }else if(f == 1){
                    self.spotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                  }else if(f > 1){
                    count += 1
                  }
                }
                self.spotCountList.insert(count, at: i)
                self.spotImagePathList?.append("")
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
              self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 0, number: i)
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
                  self.spotNameListB?.append("")
                }else if(f == 1){
                  self.spotNameListB!.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                }else if(f > 1){
                  count += 1
                }
              }
              self.spotCountList.append(count)
              self.spotImagePathList?.append("")
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(offset == 0){
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }else{
                if(self.trueSpotImagePathList![i + offset - 1] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i + offset - 1])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
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
          if(!self.firstSearchFlag){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
              self.tableView.tableFooterView?.isHidden = true
              self.tableView.tableFooterView = nil
            }
          }else{
            self.showAlert(title: "該当する結果がありません", message: "検索をやり直してください")
          }
        }
      }
      }.resume()
  }
  
  func getUserTimeline(offset:Int,flag:Int,userId:String){
    var text = "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)&user_id=\(userId)"
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
          self.firstSearchFlag = false
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
                self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 1, number: i)
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
                  }else if(f == 1){
                    self.spotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                  }else if(f > 1){
                    count += 1
                  }
                }
                self.spotCountList.insert(count, at: i)
                self.spotImagePathList?.append("")
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
              self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 0, number: i)
              if(timelineData?.record![i].user.userIcon != ""){
                let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
                let imageData = try? Data(contentsOf: url)
                let image = UIImage(data:imageData!)
                self.userImageList.append(image!)
              }else{
                self.userImageList.append(UIImage(named: "no-image.png")!)
              }
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
                  self.spotNameListB?.append("")
                }else if(f == 1){
                  self.spotNameListB!.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                }else if(f > 1){
                  count += 1
                }
              }
              self.spotCountList.append(count)
              self.spotImagePathList?.append("")
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(offset == 0){
                if(self.trueSpotImagePathList![i] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }else{
                if(self.trueSpotImagePathList![i + offset - 1] != ""){
                  let url = URL(string: self.trueSpotImagePathList![i + offset - 1])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
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
      let favoritDate : String
      let planId : Int
      let userId : String
      let plan : Plan
      let spots : [Spots]
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case favoritDate = "fav_date"
        case planId = "plan_id"
        case userId = "user_id"
        case plan = "plan"
        case spots = "spots"
        case date
      }
      struct Plan : Codable {
        let planDate : String
        let userId : String
        let planTitle : String
        let transportation : String
        let planComment : String
        let price : String
        let area : String
        enum CodingKeys: String, CodingKey {
          case planDate = "plan_date"
          case userId = "user_id"
          case planTitle = "plan_title"
          case planComment = "plan_comment"
          case transportation = "transportation"
          case price = "price"
          case area = "area"
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
  
  func favoriteTimeline(userId:String,offset:Int,flag:Int){
    var text = "http://\(globalVar.ipAddress)/api/v1/favorite/find?offset=\(offset)&limit=10&user_id=\(userId)"
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
        let timelineData = try? JSONDecoder().decode(FavoriteData.self, from: data)
        if(timelineData!.status == 200){
          self.firstSearchFlag = false
          if(flag == 1){
            let planId = self.planIdList[0]
            for_plan: for i in 0 ... (timelineData?.record?.count)! - 1{
              if(timelineData?.record![i].planId != planId){
                var count = 0
                var endFlag = false
                if(i == (timelineData?.record?.count)! - 1){
                  endFlag = true
                }
                self.getUser(userId: (timelineData?.record![i].plan.userId)!, flag: flag,number: i,endFlag: endFlag)
                self.planIdList.insert((timelineData?.record![i].planId)!, at: i)
                self.userIdList.insert((timelineData?.record![i].userId)!, at: i)
                self.planTitleList.insert((timelineData?.record![i].plan.planTitle)!, at: i)
                self.planAreaList.insert((timelineData?.record![i].plan.area)!, at: i)
                self.planTransportationList.insert((timelineData?.record![i].plan.transportation)!, at: i)
                self.planPriceList.insert((timelineData?.record![i].plan.price)!, at: i)
                self.planCommentList.insert((timelineData?.record![i].plan.planComment)!, at: i)
                self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 1, number: i)
                let planDate = (timelineData?.record![i].plan.planDate)!.prefix(10)
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
                  }else if(f == 1){
                    self.spotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                  }else if(f > 1){
                    count += 1
                  }
                }
                self.spotCountList.insert(count, at: i)
                self.spotImagePathList?.append("")
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
              var endFlag = false
              if(i == (timelineData?.record?.count)! - 1){
                endFlag = true
              }
              self.getUser(userId: (timelineData?.record![i].plan.userId)!, flag: flag,number: i,endFlag: endFlag)
              self.planIdList.append((timelineData?.record![i].planId)!)
              self.userIdList.append((timelineData?.record![i].userId)!)
              self.planTitleList.append((timelineData?.record![i].plan.planTitle)!)
              self.planAreaList.append((timelineData?.record![i].plan.area)!)
              self.planTransportationList.append((timelineData?.record![i].plan.transportation)!)
              self.planPriceList.append((timelineData?.record![i].plan.price)!)
              self.planCommentList.append((timelineData?.record![i].plan.planComment)!)
              self.getFavoriteCount(planId: self.planIdList[i], updateFlag: 0, number: i)
              let planDate = (timelineData?.record![i].plan.planDate)!.prefix(10)
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
                  self.spotNameListB?.append("")
                }else if(f == 1){
                  self.spotNameListB!.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
                }else if(f > 1){
                  count += 1
                }
              }
              self.spotCountList.append(count)
              self.spotImagePathList?.append("")
              self.trueSpotImagePathList?.append(self.spotImagePathList![0])
              if(offset == 0){
                if(self.trueSpotImagePathList![i] != ""){
                  print("真のパス",self.trueSpotImagePathList)
                  let url = URL(string: self.trueSpotImagePathList![i])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }else{
                if(self.trueSpotImagePathList![i + offset - 1] != ""){
                  print("真のパス",self.trueSpotImagePathList)
                  let url = URL(string: self.trueSpotImagePathList![i + offset - 1])!
                  let imageData = try? Data(contentsOf: url)
                  let image = UIImage(data:imageData!)
                  self.spotImageList?.append(image!)
                }else{
                  self.spotImageList?.append(UIImage(named: "no-image.png")!)
                }
              }
              self.spotImagePathList?.removeAll()
              self.planCount += 1
            }
          }
          
        }else{
          print("status",timelineData!.status)
        }
      }
      }.resume()
  }
  struct UserData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let userId : String
      let userName : String
      let generation : Int
      let gender : String
      let comment : String?
      let userIcon : String?
      let userHeader : String?
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case generation = "generation"
        case gender = "gender"
        case comment = "comment"
        case userIcon = "user_icon"
        case userHeader = "user_header"
        case date
      }
    }
  }
  
  func getUser(userId:String,flag:Int,number:Int,endFlag:Bool){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/find?user_id=\(userId)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let userData = try? JSONDecoder().decode(UserData.self, from: data)
        if(userData!.status == 200){
          if(flag == 1){
            self.userNameList.insert((userData?.record![0].userName)!, at: number)
            let url = URL(string: (userData?.record![0].userIcon)!)
            let imageData = try? Data(contentsOf: url!)
            let image = UIImage(data:imageData!)
            self.userImageList.append(image!)
          }else{
            self.userNameList.append((userData?.record![0].userName)!)
            if(userData?.record![0].userIcon != ""){
              let url = URL(string: (userData?.record![0].userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.userImageList.append(image!)
            }else{
              self.userImageList.append(UIImage(named: "no-image.png")!)
            }
          }
          if(endFlag == true){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
              print("リロードテーブル")
              self.reloadFlag = 1
              self.tableView.reloadData()
            }
          }
        }else if(userData?.status == 404){
        }
      }
      }.resume()
  }
  
  struct FavoriteDataCount : Codable{
    let status : Int?
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let rows : [Rows]?
      enum CodingKeys: String, CodingKey {
        case rows = "rows"
      }
      struct Rows : Codable{
        let favoriteDate : String?
        let planId : Int?
        let userId : String?
        enum CodingKeys: String, CodingKey {
          case favoriteDate = "fav_date"
          case planId = "plan_id"
          case userId = "user_id"
        }
      }
    }
  }
  
  func getFavoriteCount(planId:Int, updateFlag:Int, number:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/favorite/find?plan_id=\(planId)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let favoriteData = try! JSONDecoder().decode(FavoriteDataCount.self, from: data)
        if(favoriteData.status == 200){
          if(updateFlag == 0){
            self.planFavoriteCountList.append((favoriteData.record?.count)!)
          }else if(updateFlag == 1){
            self.planFavoriteCountList.insert((favoriteData.record?.count)!, at: number)
          }
        }else{
          if(updateFlag == 0){
            self.planFavoriteCountList.append(0)
          }else if(updateFlag == 1){
            self.planFavoriteCountList.insert(0, at: number)
          }
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
    self.userEditFlag = false
    let tappedLocation = sender.location(in: tableView)
    let tappedIndexPath = tableView.indexPathForRow(at: tappedLocation)
    let tappedRow = tappedIndexPath?.row
    self.nextDetailUserId = self.userIdList[tappedRow!]
    if(self.userIdList[tappedRow!] == globalVar.userId){
      self.userEditFlag = true
    }
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
    tabBar.barTintColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
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
      self.userEditFlag = true
      performSegue(withIdentifier: "toDetailUserView", sender: nil)
    default : return
      
    }
  }
  
  @objc func userIconTapped(sender : AnyObject) {
    self.userEditFlag = true
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
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
