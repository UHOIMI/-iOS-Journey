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
      
      super.viewDidLoad()
      self.navigationItem.hidesBackButton = true
      print(globalVar.userIconPath)
      
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
  
  @IBAction func tappedTimelineBurtton(_ sender: Any) {
    performSegue(withIdentifier: "toTimelineView", sender: nil)
  }
  
  
  @IBAction func tappedSearchButton(_ sender: Any) {
    performSegue(withIdentifier: "toSearchView", sender: nil)
  }
  
  @IBAction func tappedDeleteUser(_ sender: Any) {
    let realm = try! Realm()
    let users = realm.objects(UserModel.self)

    for _user in users{
      try! realm.write() {
        realm.delete(_user)
      }
    }
    performSegue(withIdentifier: "toStartView", sender: nil)
  }
  

}
