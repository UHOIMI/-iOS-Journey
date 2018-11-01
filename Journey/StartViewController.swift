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

    override func viewDidLoad() {
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
    
  @IBAction func tappedDeleteUser(_ sender: Any) {
    let realm = try! Realm()
    let users = realm.objects(UserModel.self)

    if let user = users.last {
      try! realm.write() {
        realm.delete(user)
      }
    }
  }
}
