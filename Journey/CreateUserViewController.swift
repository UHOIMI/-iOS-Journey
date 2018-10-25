//
//  CreateUserViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/22.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController , UITextFieldDelegate{

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var userIdTextField: UITextField!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var passTextField: UITextField!
  @IBOutlet weak var nextPassTextField: UITextField!
  @IBOutlet weak var generationTextField: UITextField!
  @IBOutlet weak var genderTextField: UITextField!
  
  var keyboardFlag = 0
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  override func viewDidLoad() {
        super.viewDidLoad()
    
    if myFrameSize.height >= 812{
      //scrollViewsetScrollEnabled
      scrollView.isScrollEnabled = false
    }

        // Do any additional setup after loading the view.
    }
  @IBAction func tappedBackButton(_ sender: Any) {
    performSegue(withIdentifier: "backIndexView", sender: nil)
  }
  // キーボードが現れた時に、画面全体をずらす。
  @objc func keyboardWillShow(notification: Notification?) {
    if(keyboardFlag == 0){
      let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      UIView.animate(withDuration: duration!, animations: { () in
        let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
        self.view.transform = transform
        
      })
    }
  }
  
  private func textFieldDidBeginEditing(textField: UITextField) {
    if(textField.tag == 0 || textField.tag == 1){
      keyboardFlag = 1
    }else{
      keyboardFlag = 0
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    
    super.viewWillAppear(animated)
    self.configureObserver()
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    
    super.viewWillDisappear(animated)
    self.removeObserver() // Notificationを画面が消えるときに削除
  }
  // Notificationを設定
  func configureObserver() {
    
    let notification = NotificationCenter.default
    notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  // Notificationを削除
  func removeObserver() {
    
    let notification = NotificationCenter.default
    notification.removeObserver(self)
  }
  
  // キーボードが消えたときに、画面を戻す
  @objc func keyboardWillHide(notification: Notification?) {
    if(keyboardFlag == 0){
      let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
      UIView.animate(withDuration: duration!, animations: { () in
        
        self.view.transform = CGAffineTransform.identity
      })
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
    return true
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
