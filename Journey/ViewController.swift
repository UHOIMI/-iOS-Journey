//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleTextField.placeholder = "プラン名を入力"
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

