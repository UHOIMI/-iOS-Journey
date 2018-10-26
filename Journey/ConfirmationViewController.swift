//
//  ConfirmationViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/22.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
  
  @IBOutlet weak var setIconImageView: UIImageView!
  @IBOutlet weak var userIdLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userGenerationLabel: UILabel!
  @IBOutlet weak var userGenderLabel: UILabel!
  
  let globalVar = GlobalVar.shared
  
    override func viewDidLoad() {
        super.viewDidLoad()
      userIdLabel.text = globalVar.userId
      userNameLabel.text = globalVar.userName
      userGenerationLabel.text = globalVar.userGeneration
      userGenderLabel.text = globalVar.userGender
      setIconImageView.image = globalVar.userIcon
        // Do any additional setup after loading the view.
    }
  @IBAction func tappedModificationButton(_ sender: Any) {
    performSegue(withIdentifier: "backCreateUserView", sender: nil)
  }
  @IBAction func tappedStartViewButton(_ sender: Any) {
    performSegue(withIdentifier: "toStartView", sender: nil)
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
