//
//  UINavigationViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/08/18.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class UINavigationViewController: UINavigationController {

    override func viewDidLoad() {
      super.viewDidLoad()
      
      // 白黒半々になる
      let startColor = UIColor(red: 95/255, green: 232/255, blue: 249/255, alpha: 1.0).cgColor
      let endColor = UIColor(red: 91/255, green: 178/255, blue: 253/255, alpha: 1.0).cgColor
      
      let layer = CAGradientLayer()
      layer.colors = [startColor, endColor]
      layer.frame = navigationBar.bounds
      
      navigationBar.layer.addSublayer(layer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that  be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
