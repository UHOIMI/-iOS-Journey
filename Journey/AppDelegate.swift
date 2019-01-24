//
//  AppDelegate.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import RealmSwift
import Realm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  let globalVar = GlobalVar.shared

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    GMSServices.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    GMSPlacesClient.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    GMSServices.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    var currentUser : String = ""
    let realm = try! Realm()
    let user = realm.objects(UserModel.self)
    for _user in user {
      print("名前",_user.user_name)
      currentUser = _user.user_name
      globalVar.userGenerationInt = _user.user_generation
      globalVar.userPostPlan(userId: _user.user_id)
    }
    //currentuser = nil
    //ユーザーがいない場合IndexViewに遷移
//    searchTimeline(offset: 0, generation: _user.user_generation)
    
    if (currentUser == ""){
      //windowを生成
      self.window = UIWindow(frame: UIScreen.main.bounds)
      //Storyboardを指定
      let storyboard = UIStoryboard(name: "Main", bundle: nil)//Viewcontrollerを指定
      let initialViewController = storyboard.instantiateViewController(withIdentifier: "index")
      //rootViewControllerに入れる
      self.window?.rootViewController = initialViewController
      //表示
      self.window?.makeKeyAndVisible()
    }else{
      searchTimeline(offset: 0, generation: globalVar.userGenerationInt)
      getTimeline(offset: 0)
      for _user in user {
        globalVar.token = _user.user_token
        globalVar.userName = _user.user_name
        globalVar.userPass = _user.user_pass
        globalVar.userComment = _user.user_comment
        globalVar.userId = _user.user_id
        print("is,pass1",_user.user_id,_user.user_pass,_user.user_name)
        globalVar.userIconPath = _user.user_image
        globalVar.userHeaderPath = _user.user_header
        settingData(gender: _user.user_gender, generation: _user.user_generation)
        loginUser(id: _user.user_id, pass: _user.user_pass)
        if(globalVar.userHeaderPath == "" || globalVar.userHeaderPath == "nil"){
          globalVar.userHeader = UIImage(named: "mountain")!
        }else{
          let url = URL(string: globalVar.userHeaderPath)!
          let imageData = try? Data(contentsOf: url)
          let image = UIImage(data:imageData!)
          globalVar.userHeader = image!
        }
        if(globalVar.userIconPath == "" || globalVar.userIconPath == "error"){
          globalVar.userIcon = UIImage(named: "no-image.png")
        }else{
          let iconUrl = URL(string: globalVar.userIconPath)!
          let iconData = try? Data(contentsOf: iconUrl)
          let iconImage = UIImage(data:iconData!)
          globalVar.userIcon = iconImage!
        }
      }
    }
    return true
  }
  
  func loginUser(id:String,pass:String){
    print("id,pass",id,pass)
    let str = "user_id=\(id)&user_pass=\(pass)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/login")
    var request = URLRequest(url: url!)
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
        var strData:String = String(data: data, encoding: .utf8)!
          for _ in 0...1{
            if let range = strData.range(of: "\""){
              strData.removeSubrange(range)
            }
          print("出力",strData)
          self.globalVar.token = strData
        }
      }
      }.resume()
  }
  
  func settingData(gender:String,generation:Int){
    switch gender {
    case "男":
      globalVar.userGender = "男性"
      break
    case "女":
      globalVar.userGender = "女性"
      break
    default:
      break
    }
    switch generation {
    case 0:
      globalVar.userGeneration = "10歳未満"
      break
    case 10:
      globalVar.userGeneration = "10代"
      break
    case 20:
      globalVar.userGeneration = "20代"
      break
    case 30:
      globalVar.userGeneration = "30代"
      break
    case 40:
      globalVar.userGeneration = "40代"
      break
    case 50:
      globalVar.userGeneration = "50代"
      break
    case 60:
      globalVar.userGeneration = "60代"
      break
    case 70:
      globalVar.userGeneration = "70代"
      break
    case 80:
      globalVar.userGeneration = "80代"
      break
    case 90:
      globalVar.userGeneration = "90代"
      break
    case 100:
      globalVar.userGeneration = "100歳以上"
      break
    default:
      break
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
      */
      let container = NSPersistentContainer(name: "Journey")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               
              /*
               Typical reasons for an error here include:
               * The parent directory does not exist, cannot be created, or disallows writing.
               * The persistent store is not accessible, due to permissions or data protection when the device is locked.
               * The device is out of space.
               * The store could not be migrated to the current model version.
               Check the error message to determine what the actual problem was.
               */
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      let context = persistentContainer.viewContext
      if context.hasChanges {
          do {
              try context.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
  func getTimeline(offset:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)&limit=3")
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
          for i in 0 ... 2{
            var count = 0
            self.globalVar.newPlanIdList.append((timelineData?.record![i].planId)!)
            self.globalVar.newUserIdList.append((timelineData?.record![i].userId)!)
            self.globalVar.newPlanTitleList.append((timelineData?.record![i].planTitle)!)
            self.globalVar.newUserNameList.append((timelineData?.record![i].user.userName)!)
            self.globalVar.newPlanAreaList.append((timelineData?.record![i].area)!)
            self.globalVar.newPlanTransportationList.append((timelineData?.record![i].transportation)!)
            self.globalVar.newPlanPriceList.append((timelineData?.record![i].price)!)
            self.globalVar.newPlanCommentList.append((timelineData?.record![i].planComment)!)
            
            if(timelineData?.record![i].user.userIcon != ""){
              let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.newUserImageList.append(image!)
            }else{
              self.globalVar.newUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (timelineData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.globalVar.newDateList.append("\(date)日")
            
            for f in 0 ... (timelineData?.record![i].spots.count)! - 1{
              if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageA)!)
              }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageB)!)
              }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageC)!)
              }
              if(f == 0){
                self.globalVar.newSpotNameListA.append((timelineData?.record![i].spots[f].spotTitle)!)
                self.globalVar.newSpotNameListB?.append("")
              }else if(f == 1){
                self.globalVar.newSpotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.globalVar.newSpotCountList.append(count)
            self.globalVar.newSpotImagePathList?.append("")
            self.globalVar.newTrueSpotImagePathList?.append(self.globalVar.newSpotImagePathList![0])
            if(self.globalVar.newTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.globalVar.newTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.newSpotImageList?.append(image!)
            }else{
              self.globalVar.newSpotImageList?.append(UIImage(named: "no-image.png")!)
            }
            self.globalVar.newSpotImagePathList?.removeAll()
            self.globalVar.newPlanCount += 1
          }
        }
      }else{
      }
    }.resume()
  }
  
  
  func searchTimeline(offset:Int,generation:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/search/find?generation=\(generation)&limit=3")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let searchData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(searchData!.status == 200){
          for i in 0 ... 2{
            var count = 0
            self.globalVar.searchPlanIdList.append((searchData?.record![i].planId)!)
            self.globalVar.searchUserIdList.append((searchData?.record![i].userId)!)
            self.globalVar.searchPlanTitleList.append((searchData?.record![i].planTitle)!)
            self.globalVar.searchUserNameList.append((searchData?.record![i].user.userName)!)
            self.globalVar.searchPlanAreaList.append((searchData?.record![i].area)!)
            self.globalVar.searchPlanTransportationList.append((searchData?.record![i].transportation)!)
            self.globalVar.searchPlanPriceList.append((searchData?.record![i].price)!)
            self.globalVar.searchPlanCommentList.append((searchData?.record![i].planComment)!)
            if(searchData?.record![i].user.userIcon != ""){
              let url = URL(string: (searchData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.searchUserImageList.append(image!)
            }else{
              self.globalVar.searchUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (searchData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.globalVar.searchDateList.append("\(date)日")
            for f in 0 ... (searchData?.record![i].spots.count)! - 1{
              if((searchData?.record![i].spots[f].spotImageA)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageA)!)
              }else if((searchData?.record![i].spots[f].spotImageB)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageB)!)
              }else if((searchData?.record![i].spots[f].spotImageC)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageC)!)
              }
              if(f == 0){
                self.globalVar.searchSpotNameListA.append((searchData?.record![i].spots[f].spotTitle)!)
                self.globalVar.searchSpotNameListB?.append("")
              }else if(f == 1){
                self.globalVar.searchSpotNameListB?.insert((searchData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.globalVar.searchSpotCountList.append(count)
            self.globalVar.searchSpotImagePathList?.append("")
            self.globalVar.searchTrueSpotImagePathList?.append(self.globalVar.searchSpotImagePathList![0])
            if(self.globalVar.searchTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.globalVar.searchTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.searchSpotImageList?.append(image!)
            }else{
              self.globalVar.searchSpotImageList?.append(UIImage(named: "no-image.png")!)
            }
            self.globalVar.searchSpotImagePathList?.removeAll()
            self.globalVar.searchPlanCount += 1
          }
        }
      }else{
      }
      }.resume()
    
  }

}

class GlobalVar{
  
  let splash = SplashViewController.self
  private init(){}
  static let shared = GlobalVar()
  
  var selectSpot:Array = ["スポットを追加"]
  var spotDataList : [ListSpotModel] = []
  var planTitle : String = ""
  var planArea : String = ""
  var planText : String = ""
  var planPrice : String = ""
  var selectCount : Int = 0
  var spotImageA = Array(repeating:"", count:20)
  var spotImageB = Array(repeating:"", count:20)
  var spotImageC = Array(repeating:"", count:20)
  
  var userId : String = ""
  var userName : String = ""
  var userPass : String = ""
  var userGender : String = ""
  var userGeneration : String = ""
  var userIconPath : String = ""
  var userIcon:UIImage?
//  let ipAddress = "api.mino.asia:3001"
  let ipAddress = "192.168.100.161:3000"
  var userComment = ""
  var userHeaderPath = ""
  var userHeader = UIImage()
  var userGenerationInt = 0
  
  //新着三件用
  var newPlanIdList : [Int] = []
  var newUserIdList : [String] = []
  var newUserNameList : [String] = []
  var newPlanTitleList : [String] = []
  var newUserImagePathList : [String] = []
  var newDateList : [String] = []
  var newSpotImageSetFlag : [Int] = []
  var newSpotCountList : [Int] = []
  var newSpotNameListA : [String] = []
  var newSpotNameListB : [String]? = []
  var newSpotImagePathList : [String]? = []
  var newTrueSpotImagePathList : [String]? = []
  var newSpotImageList : [UIImage]? = []
  var newUserImageList : [UIImage] = []
  var newPlanAreaList : [String] = []
  var newPlanTransportationList : [String] = []
  var newPlanPriceList : [String] = []
  var newPlanCommentList : [String] = []
  var newPlanCount = 0
  
  //年代別新着3件用
  var searchPlanIdList : [Int] = []
  var searchUserIdList : [String] = []
  var searchUserNameList : [String] = []
  var searchPlanTitleList : [String] = []
  var searchUserImagePathList : [String] = []
  var searchDateList : [String] = []
  var searchSpotImageSetFlag : [Int] = []
  var searchSpotCountList : [Int] = []
  var searchSpotNameListA : [String] = []
  var searchSpotNameListB : [String]? = []
  var searchSpotImagePathList : [String]? = []
  var searchTrueSpotImagePathList : [String]? = []
  var searchSpotImageList : [UIImage]? = []
  var searchUserImageList : [UIImage] = []
  var searchPlanAreaList : [String] = []
  var searchPlanTransportationList : [String] = []
  var searchPlanPriceList : [String] = []
  var searchPlanCommentList : [String] = []
  var searchPlanCount = 0
  
  //投稿した1件のプラン
  var postPlanId : Int = 0
  var postUserId : String = ""
  var postUserName : String = ""
  var postPlanTitle : String = ""
  var postUserImagePath : String = ""
  var postDate : String = ""
  var postSpotImageSetFlag : Int = 0
  var postSpotNameA : String = ""
  var postSpotNameB : String = ""
  var postSpotCount : Int = 0
  var postSpotImagePathList : [String]? = []
  var postTrueSpotImagePath : String = ""
  var postSpotImage : UIImage = UIImage(named: "no-image.png")!
  var postUserImage : UIImage = UIImage(named: "no-image.png")!
  var postPlanArea : String = ""
  var postPlanTransportation : String = ""
  var postPlanPrice : String = ""
  var postPlanComment : String = ""
  
  
  
  var token : String = ""
//  let ipAddress = "172.20.10.9:443"
  
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
  
  func userPostPlan(userId : String){
    let url = URL(string: "http://\(ipAddress)/api/v1/search/find?user_id=\(userId)&limit=1")
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
        self.postPlanId = (timelineData?.record![0].planId)!
        self.postUserId = (timelineData?.record![0].userId)!
        self.postPlanTitle = (timelineData?.record![0].planTitle)!
        self.postUserName = (timelineData?.record![0].user.userName)!
        self.postPlanArea = (timelineData?.record![0].area)!
        self.postPlanTransportation = (timelineData?.record![0].transportation)!
        self.postPlanPrice = (timelineData?.record![0].price)!
        self.postPlanComment = (timelineData?.record![0].planComment)!
        
        if(timelineData?.record![0].user.userIcon != ""){
          let url = URL(string: (timelineData?.record![0].user.userIcon)!)!
          let imageData = try? Data(contentsOf: url)
          let image = UIImage(data:imageData!)
          self.postUserImage = image!
        }else{
          self.postUserImage = UIImage(named: "no-image.png")!
        }
        let planDate = (timelineData?.record![0].planDate)!.prefix(10)
        var date = planDate.suffix(5)
        if let range = date.range(of: "-"){
          date.replaceSubrange(range, with: "月")
        }
        self.postDate = "\(date)日"
        for i in 0 ... (timelineData?.record![0].spots.count)! - 1{
          if((timelineData?.record![0].spots[i].spotImageA)! != ""){
            self.postSpotImagePathList?.append((timelineData?.record![0].spots[i].spotImageA)!)
          }else if((timelineData?.record![0].spots[i].spotImageB)! != ""){
            self.postSpotImagePathList?.append((timelineData?.record![0].spots[i].spotImageB)!)
          }else if((timelineData?.record![0].spots[i].spotImageC)! != ""){
            self.postSpotImagePathList?.append((timelineData?.record![0].spots[i].spotImageC)!)
          }
          if(1 == 0){
            self.postSpotNameA = timelineData!.record![0].spots[i].spotTitle
          }else if(i == 1){
            self.postSpotNameB = (timelineData?.record![0].spots[i].spotTitle)!
          }else if (i > 1){
            self.postSpotCount += 1
          }
        }
        
        self.postSpotImagePathList?.append("")
        self.postTrueSpotImagePath = self.postSpotImagePathList![0]
        if(self.postTrueSpotImagePath != ""){
          let url = URL(string: self.postTrueSpotImagePath)!
          let imageData = try? Data(contentsOf: url)
          let image = UIImage(data:imageData!)
          self.postSpotImage = image!
        }else{
          self.postSpotImage = UIImage(named: "no-image.png")!
        }
        self.postSpotImagePathList?.removeAll()
      }
    }.resume()
  }
    
  func getTimeline(offset:Int){
    let url = URL(string: "http://\(ipAddress)/api/v1/timeline/find?offset=\(offset)&limit=3")
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
          for i in 0 ... 2{
            var count = 0
            self.newPlanIdList.insert((timelineData?.record![i].planId)!, at: i)
            self.newUserIdList.insert((timelineData?.record![i].userId)!, at: i)
            self.newPlanTitleList.insert((timelineData?.record![i].planTitle)!, at: i)
            self.newUserNameList.insert((timelineData?.record![i].user.userName)!, at: i)
            self.newPlanAreaList.insert((timelineData?.record![i].area)!, at: i)
            self.newPlanTransportationList.insert((timelineData?.record![i].transportation)!, at: i)
            self.newPlanPriceList.insert((timelineData?.record![i].price)!, at: i)
            self.newPlanCommentList.insert((timelineData?.record![i].planComment)!, at: i)
            if(timelineData?.record![i].user.userIcon != ""){
              let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.newUserImageList.append(image!)
            }else{
              self.newUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (timelineData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.newDateList.append("\(date)日")
            for f in 0 ... (timelineData?.record![0].spots.count)! - 1{
              if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                self.newSpotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageA)!, at: i)
              }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                self.newSpotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageB)!, at: i)
              }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                self.newSpotImagePathList?.insert((timelineData?.record![i].spots[f].spotImageC)!, at: i)
              }
              if(f == 0){
                self.newSpotNameListA.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f == 1){
                self.newSpotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.newSpotCountList.insert(count, at: i)
            self.newSpotImagePathList?.append("")
            self.newTrueSpotImagePathList?.append(self.newSpotImagePathList![0])
            if(self.newTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.newTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.newSpotImageList?.insert(image!, at: i)
            }else{
              self.newSpotImageList?.insert(UIImage(named: "no-image.png")!, at: i)
            }
            self.newSpotImagePathList?.removeAll()
            self.newPlanCount += 1
          }
        }
      }else{
      }
    }.resume()
  }
  func searchTimeline(offset:Int,generation:Int){
    let url = URL(string: "http://\(ipAddress)/api/v1/search/find?generation=\(generation)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let searchData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(searchData!.status == 200){
          for i in 0 ... 2{
            var count = 0
            self.searchPlanIdList.insert((searchData?.record![i].planId)!, at: i)
            self.searchUserIdList.insert((searchData?.record![i].userId)!, at: i)
            self.searchPlanTitleList.insert((searchData?.record![i].planTitle)!, at: i)
            self.searchUserNameList.insert((searchData?.record![i].user.userName)!, at: i)
            self.searchPlanAreaList.insert((searchData?.record![i].area)!, at: i)
            self.searchPlanTransportationList.insert((searchData?.record![i].transportation)!, at: i)
            self.searchPlanPriceList.insert((searchData?.record![i].price)!, at: i)
            self.searchPlanCommentList.insert((searchData?.record![i].planComment)!, at: i)
            if(searchData?.record![i].user.userIcon != ""){
              let url = URL(string: (searchData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.searchUserImageList.append(image!)
            }else{
              self.searchUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (searchData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.searchDateList.append("\(date)日")
            for f in 0 ... (searchData?.record![0].spots.count)! - 1{
              if((searchData?.record![i].spots[f].spotImageA)! != ""){
                self.searchSpotImagePathList?.insert((searchData?.record![i].spots[f].spotImageA)!, at: i)
              }else if((searchData?.record![i].spots[f].spotImageB)! != ""){
                self.searchSpotImagePathList?.insert((searchData?.record![i].spots[f].spotImageB)!, at: i)
              }else if((searchData?.record![i].spots[f].spotImageC)! != ""){
                self.searchSpotImagePathList?.insert((searchData?.record![i].spots[f].spotImageC)!, at: i)
              }
              if(f == 0){
                self.searchSpotNameListA.insert((searchData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f == 1){
                self.searchSpotNameListB?.insert((searchData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.searchSpotCountList.insert(count, at: i)
            self.searchSpotImagePathList?.append("")
            self.searchTrueSpotImagePathList?.append(self.searchSpotImagePathList![0])
            if(self.searchTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.searchTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.searchSpotImageList?.insert(image!, at: i)
            }else{
              self.searchSpotImageList?.insert(UIImage(named: "no-image.png")!, at: i)
            }
            self.searchSpotImagePathList?.removeAll()
            self.searchPlanCount += 1
          }
        }
      }else{
      }
    }.resume()
  }
}

