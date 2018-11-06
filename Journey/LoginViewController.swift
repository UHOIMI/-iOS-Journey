//
//  LoginViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/22.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {

  @IBOutlet weak var userIdTextField: UITextField!
  @IBOutlet weak var userPassTextField: UITextField!
  

  let globalVar = GlobalVar.shared

  override func viewDidLoad() {
        super.viewDidLoad()
    
    userIdTextField.placeholder = "ユーザーIDを入力"
    userPassTextField.placeholder = "パスワードを入力"
    userPassTextField.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }
    
  @IBAction func tappedLoginButton(_ sender: Any) {
    loginUser()
  }
  
  func loginUser(){
    let str = "user_id=\(userIdTextField.text!)&user_pass=\(userPassTextField.text!)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/login")
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    // POSTするデータをBodyとして設定
    request.httpBody = str.data(using: .utf8)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: .utf8) ?? "")
        var strData:String = String(data: data, encoding: .utf8)!
        let nsStr:NSString = strData as NSString
        let firstStr : String = nsStr.substring(to: 1)
        if(firstStr == "{"){
          self.showAlert(title: "IDまたはパスワードが間違っています。", message: "入力し直してください")
        }else{
          for _ in 0...1{
            if let range = strData.range(of: "\""){
              strData.removeSubrange(range)
            }
          }
          self.saveUser(id: self.userIdTextField.text!, pass: self.userPassTextField.text!, token: strData)
          self.testRealm()
          print("出力",strData)
          self.globalVar.userId = self.userIdTextField.text!
          self.globalVar.userPass = self.userPassTextField.text!
          self.globalVar.token = strData
          self.performSegue(withIdentifier: "toStartView", sender: nil)
        }
      }
    }.resume()
  }
  
  func showAlert(title:String,message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let cancelButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
    alert.addAction(cancelButton)
    self.present(alert, animated: true, completion: nil)
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
  
  // キーボードが現れた時に、画面全体をずらす。
  @objc func keyboardWillShow(notification: Notification?) {
    let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    UIView.animate(withDuration: duration!, animations: { () in
      let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
      self.view.transform = transform
      
    })
  }
  
  // キーボードが消えたときに、画面を戻す
  @objc func keyboardWillHide(notification: Notification?) {
    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
    UIView.animate(withDuration: duration!, animations: { () in
      self.view.transform = CGAffineTransform.identity
    })
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
    return true
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
  
  func testRealm(){
    let realm = try! Realm()
    
    let user = realm.objects(UserModel.self)
    for _user in user {
      print("れるむテストid", _user.user_id)
      print("れるむテストpass", _user.user_pass)
      print("れるむテストtoken", _user.user_token)
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
