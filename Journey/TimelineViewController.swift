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

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  var ActivityIndicator: UIActivityIndicatorView!
  let formatter = DateFormatter()
  
  let globalVar = GlobalVar.shared
  
  var sampledatas = [1,2]
  var isaddload:Bool = true
  var planIdList : [Int] = []
  var userIdList : [String] = []
  var planTitleList : [String] = []
  var userImagePathList : [String] = []
  var dateList : [String] = []
  var spotImageSetFlag : [Int] = []
  var spotCountList : [Int] = []
  var spotNameListA : [String] = []
  var spotNameListB : [String]? = []
  var spotImagePathList : [String]? = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getPlan()
//    tableView.reloadData()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
    //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
//    tableView.register(cellType: LoaddingTableViewCell.self)
//    let footerCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoaddingTableViewCell")!
//    (footerCell as! LoaddingTableViewCell).startAnimationg()
//    let footerView: UIView = footerCell.contentView
//    tableView.tableFooterView = footerView
//    tableView.addSubview(refreshControl)
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
    tableView.reloadData()
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
    cell.planNameLabel.text = sampledatas[indexPath.row].description + planTitleList[indexPath.row]
    cell.planSpotNameLabel1.text = spotNameListA[indexPath.row]
    cell.planSpotNameLabel2.text = spotNameListA[indexPath.row]
    cell.planFavoriteLabel.text = 99999.description
    cell.planImageView.image = UIImage(named: "no-image.png")
    cell.planDateLabel.text = dateList[indexPath.row]
    let iconUrl = URL(string: userImagePathList[indexPath.row])!
    let iconData = try? Data(contentsOf: iconUrl)
    cell.planUserIconImageView.image = UIImage(data:iconData!)
    cell.planUserIconImageView.layer.cornerRadius = 40 * 0.5
    print(cell.planUserIconImageView.frame.width)
    cell.planUserIconImageView.clipsToBounds = true
//    cell.planDateLabel.text = String(date:dateList[indexPath.row])
    //cell.textLabel?.text = "\(sampledatas[indexPath.row])"
    self.ActivityIndicator.stopAnimating()
    return cell
  }
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
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
  
  struct PlanData : Codable{
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
      let transportation : String?
      let price : String?
      let area : String?
      let spotIdA : Int?
      let spotIdB : Int?
      let spotIdC : Int?
      let spotIdD : Int?
      let spotIdE : Int?
      let spotIdF : Int?
      let spotIdG : Int?
      let spotIdH : Int?
      let spotIdI : Int?
      let spotIdJ : Int?
      let spotIdK : Int?
      let spotIdL : Int?
      let spotIdM : Int?
      let spotIdN : Int?
      let spotIdO : Int?
      let spotIdP : Int?
      let spotIdQ : Int?
      let spotIdR : Int?
      let spotIdS : Int?
      let spotIdT : Int?
      let planDate : String
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case userId = "user_id"
        case planTitle = "plan_title"
        case planComment = "spot_comment"
        case transportation = "transportation"
        case price = "price"
        case area = "area"
        case spotIdA = "spot_id_a"
        case spotIdB = "spot_id_b"
        case spotIdC = "spot_id_c"
        case spotIdD = "spot_id_d"
        case spotIdE = "spot_id_e"
        case spotIdF = "spot_id_f"
        case spotIdG = "spot_id_g"
        case spotIdH = "spot_id_h"
        case spotIdI = "spot_id_i"
        case spotIdJ = "spot_id_j"
        case spotIdK = "spot_id_k"
        case spotIdL = "spot_id_l"
        case spotIdM = "spot_id_m"
        case spotIdN = "spot_id_n"
        case spotIdO = "spot_id_o"
        case spotIdP = "spot_id_p"
        case spotIdQ = "spot_id_q"
        case spotIdR = "spot_id_r"
        case spotIdS = "spot_id_s"
        case spotIdT = "spot_id_t"
        case planDate = "plan_date"
        case date
      }
    }
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
      let spotId : Int
      let userId : String
      let spotTitle : String
      let spotAddress : SpotAddress
      let spotComment : String?
      let spotImageA : String?
      let spotImageB : String?
      let spotImageC : String?
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case spotId = "spot_id"
        case userId = "user_id"
        case spotTitle = "spot_title"
        case spotAddress = "spot_address"
        case spotComment = "spot_comment"
        case spotImageA = "spot_image_a"
        case spotImageB = "spot_image_b"
        case spotImageC = "spot_image_c"
        case date = "date"
      }
      struct SpotAddress : Codable{
        let x : Double
        let y : Double
        enum CodingKeys: String, CodingKey {
          case x = "lat"
          case y = "lng"
        }
      }
    }
  }
  
  func getPlan(){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/timeline/find")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let planData = try? JSONDecoder().decode(PlanData.self, from: data)
        if(planData!.status == 200){
          for i in 0...1{
            self.planIdList.append(planData!.record![i].planId)
            self.planTitleList.append(planData!.record![i].planTitle)
            self.userIdList.append(planData!.record![i].userId)
            
            var strDate = planData!.record![i].planDate
            for _ in 0...1{
              if let range = strDate.range(of: "-") {
                strDate.replaceSubrange(range, with: "/")
                print("日付:",strDate)
              }
            }
            let prefixDate = strDate.prefix(11)
            var suffixDate = prefixDate.suffix(6)
            if let range = suffixDate.range(of: "/") {
              suffixDate.replaceSubrange(range, with: "月")
              print("日付:",suffixDate)
            }
            if let range = suffixDate.range(of: "T") {
              suffixDate.replaceSubrange(range, with: "日")
              print("日付:",suffixDate)
            }
            print("日付",planData!.record![i].planDate)
            self.dateList.append(String(suffixDate))
            self.getUserImage(userId: self.userIdList[i], number: i)
            self.spotImageSetFlag.append(0)
            var count = 0
            self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "A", number: i)
            print("プランID",self.planIdList[i])
            if(planData!.record![i].spotIdB != nil){
              self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "B", number: i)
              if(planData!.record![i].spotIdC != nil){
                count += 1
                if(self.spotImageSetFlag[i] == 0){
                  self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                }
                if(planData!.record![i].spotIdC != nil){
                  count += 1
                  if(self.spotImageSetFlag[i] == 0){
                    self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                  }
                  if(planData!.record![i].spotIdD != nil){
                    count += 1
                    if(self.spotImageSetFlag[i] == 0){
                      self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                    }
                    if(planData!.record![i].spotIdE != nil){
                      count += 1
                      if(self.spotImageSetFlag[i] == 0){
                        self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                      }
                      if(planData!.record![i].spotIdF != nil){
                        count += 1
                        if(self.spotImageSetFlag[i] == 0){
                          self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                        }
                        if(planData!.record![i].spotIdG != nil){
                          count += 1
                          if(self.spotImageSetFlag[i] == 0){
                            self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                          }
                          if(planData!.record![i].spotIdH != nil){
                            count += 1
                            if(self.spotImageSetFlag[i] == 0){
                              self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                            }
                            if(planData!.record![i].spotIdI != nil){
                              count += 1
                              if(self.spotImageSetFlag[i] == 0){
                                self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                              }
                              if(planData!.record![i].spotIdJ != nil){
                                count += 1
                                if(self.spotImageSetFlag[i] == 0){
                                  self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                }
                                if(planData!.record![i].spotIdK != nil){
                                  count += 1
                                  if(self.spotImageSetFlag[i] == 0){
                                    self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                  }
                                  if(planData!.record![i].spotIdL != nil){
                                    count += 1
                                    if(self.spotImageSetFlag[i] == 0){
                                      self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                    }
                                    if(planData!.record![i].spotIdM != nil){
                                      count += 1
                                      if(self.spotImageSetFlag[i] == 0){
                                        self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                      }
                                      if(planData!.record![i].spotIdN != nil){
                                        count += 1
                                        if(self.spotImageSetFlag[i] == 0){
                                          self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                        }
                                        if(planData!.record![i].spotIdO != nil){
                                          count += 1
                                          if(self.spotImageSetFlag[i] == 0){
                                            self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                          }
                                          if(planData!.record![i].spotIdP != nil){
                                            count += 1
                                            if(self.spotImageSetFlag[i] == 0){
                                              self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                            }
                                            if(planData!.record![i].spotIdQ != nil){
                                              count += 1
                                              if(self.spotImageSetFlag[i] == 0){
                                                self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                              }
                                              if(planData!.record![i].spotIdR != nil){
                                                count += 1
                                                if(self.spotImageSetFlag[i] == 0){
                                                  self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                                }
                                                if(planData!.record![i].spotIdS != nil){
                                                  count += 1
                                                  if(self.spotImageSetFlag[i] == 0){
                                                    self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                                  }
                                                  if(planData!.record![i].spotIdT != nil){
                                                    count += 1
                                                    if(self.spotImageSetFlag[i] == 0){
                                                      self.getSpot(spotId: (planData?.record![i].spotIdA)!, flag: self.spotImageSetFlag[i], spot: "C", number: i)
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }else{
              self.spotNameListB?.append("nil")
            }
          }
        }
      }
    }.resume()
  }
  func getUserImage(userId:String,number :Int){
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
          self.userImagePathList.append((userData?.record![0].userIcon)!)
          print(self.userImagePathList[0])
        }
      }
    }.resume()
  }
  
  func getSpot(spotId:Int, flag:Int, spot:String, number:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/spot/find?spot_id=\(spotId)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let spotData = try! JSONDecoder().decode(SpotData.self, from: data)
        if (spotData.status == 200){
          if(spot == "A"){
            self.spotNameListA.append(spotData.record![0].spotTitle)
            if(spotData.record![0].spotImageA != nil){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageA!)
            }else if(spotData.record![0].spotImageB != nil){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageB!)
            }else if(spotData.record![0].spotImageC != nil){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageC!)
            }
          }else if(spot == "B"){
            self.spotNameListB?.append(spotData.record![0].spotTitle)
            if(spotData.record![0].spotImageA != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageA!)
            }else if(spotData.record![0].spotImageB != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageB!)
            }else if(spotData.record![0].spotImageC != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageC!)
            }
          }else{
            if(spotData.record![0].spotImageA != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageA!)
            }else if(spotData.record![0].spotImageB != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageB!)
            }else if(spotData.record![0].spotImageC != nil && self.spotImageSetFlag[number] == 0){
              self.spotImageSetFlag[number] = 1
              self.spotImagePathList?.append(spotData.record![0].spotImageC!)
            }
          }
          print("画像",self.spotImagePathList!)
          print("A",self.spotNameListA)
          print("B",self.spotNameListB!)
          if(number == 1){
            self.tableView.reloadData()
          }
        }
      }
    }.resume()
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
