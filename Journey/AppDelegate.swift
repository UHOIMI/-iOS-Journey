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
    }
    //currentuser = nil
    //ユーザーがいない場合IndexViewに遷移
    getTimeline(offset: 0)
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
          for i in 0 ... (timelineData?.record?.count)! - 1{
            var count = 0
            self.globalVar.newPlanIdList.append((timelineData?.record![i].planId)!)
            self.globalVar.newUserIdList.append((timelineData?.record![i].userId)!)
            self.globalVar.newPlanTitleList.append((timelineData?.record![i].planTitle)!)
            self.globalVar.newUserNameList.append((timelineData?.record![i].user.userName)!)
            self.globalVar.newPlanAreaList.append((timelineData?.record![i].area)!)
            self.globalVar.newPlanTransportationList.append((timelineData?.record![i].transportation)!)
            self.globalVar.newPlanPriceList.append((timelineData?.record![i].price)!)
            self.globalVar.newPlanCommentList.append((timelineData?.record![i].planComment)!)
            let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
            let imageData = try? Data(contentsOf: url)
            let image = UIImage(data:imageData!)
            self.globalVar.newUserImageList.append(image!)
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
                self.globalVar.newSpotNameListB?.append("nil")
              }else if(f == 1){
                self.globalVar.newSpotNameListB?[i] = (timelineData?.record![i].spots[f].spotTitle)!
              }else{
                count += 1
              }
            }
            self.globalVar.newSpotImagePathList?.append("")
            self.globalVar.newSpotCountList.append(count)
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
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//          print("リロードテーブル")
//          self.reloadFlag = 1
//          self.tableView.reloadData()
//        }
      }else{
//        print("status",timelineData!.status)
      }
    }.resume()
  }

}

class GlobalVar{
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
  let ipAddress = "172.20.10.9:3000"
  var userComment = ""
  var userHeaderPath = ""
  var userHeader = UIImage()
  
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
  
  var token : String = ""
//  let ipAddress = "35.200.26.70:443"
}

