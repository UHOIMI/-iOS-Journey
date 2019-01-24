//
//  SplashViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/12/26.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
      toHome()
      
        // Do any additional setup after loading the view.
    }
  
  func toHome(){
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +  2.0) {
      self.performSegue(withIdentifier: "toHomeView", sender: nil)
    }
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
