//
//  UINavigationViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/08/18.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
      super.viewDidLoad()
      //　ナビゲーションバーの背景色
      let image:UIImage = UIImage(named: "gradation.png")!
      navigationBar.setBackgroundImage(image, for: .default)
      // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
      navigationBar.tintColor = .black
      // ナビゲーションバーのテキストを変更する
      navigationBar.titleTextAttributes = [
        // 文字の色
        .foregroundColor: UIColor.black
      ]

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
