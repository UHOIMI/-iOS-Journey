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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    GMSServices.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    GMSPlacesClient.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    GMSServices.provideAPIKey("AIzaSyAu4shygs1dkfd--14xncAtce8etYwP9EM")
    var currentuser:String? = nil
    let realm = try! Realm()
    let user = realm.objects(UserModel.self)
    for _user in user {
      currentuser = _user.user_name
    }
    //currentuser = nil
    //ユーザーがいない場合IndexViewに遷移
    if (currentuser == nil){
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
      //ユーザーがいる場合Storyboardでチェックの入っているIs Initial View Controllerに遷移する
    }
    return true
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
  var userIcon = UIImage()
  let ipAddress = "172.20.10.3:3000"
  var userComment = ""
  
  var token : String = ""
//  let ipAddress = "35.200.26.70:443"
}

