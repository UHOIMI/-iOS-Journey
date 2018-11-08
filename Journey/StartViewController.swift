//
//  StartViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/08/05.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class StartViewController: UIViewController {
  
  let globalVar = GlobalVar.shared

    override func viewDidLoad() {
      
      self.saveUser(id: globalVar.userId, pass: globalVar.userPass, token: globalVar.token)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func tappedPostButton(_ sender: Any) {
    performSegue(withIdentifier: "toPostView", sender: nil)
  }
  
    @IBAction func tappedAddButton(_ sender: Any) {
        performSegue(withIdentifier: "toPutSpotView", sender: nil)
    }
    
    @IBAction func tappedListButton(_ sender: Any) {
        performSegue(withIdentifier: "toSpotListView", sender: nil)
    }
  
  
  @IBAction func tappedUserDetailButton(_ sender: Any) {
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
  }
  
  func saveUser(id : String, pass : String, token : String){
    let realm = try! Realm()
    let userModel = UserModel()
    
    userModel.user_id = id
    userModel.user_pass = pass
    userModel.user_comment = "こんにちは"
    userModel.user_token = token
    
    try! realm.write() {
      realm.add(userModel, update: true)
    }
  }
    
  @IBAction func tappedDeleteUser(_ sender: Any) {
    let realm = try! Realm()
    let users = realm.objects(UserModel.self)

    if let user = users.last {
      try! realm.write() {
        realm.delete(user)
      }
    }
    performSegue(withIdentifier: "toStartView", sender: nil)
  }
}
