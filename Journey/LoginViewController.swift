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
    
    self.navigationItem.hidesBackButton = true
    userIdTextField.placeholder = "ユーザーIDを入力"
    userPassTextField.placeholder = "パスワードを入力"
    userPassTextField.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }
    
  @IBAction func tappedLoginButton(_ sender: Any) {
    userIdTextField.endEditing(true)
    userPassTextField.endEditing(true)
    if (userIdTextField.text == ""){
      showAlert(title: "ユーザーIDが入力されていません", message: "ユーザーIDを入力してください")
    }else if(userPassTextField.text == ""){
      showAlert(title: "パスワードが入力されていません", message: "パスワードを入力してください")
    }else{
      globalVar.userId = userIdTextField.text!
      globalVar.userPass = userPassTextField.text!
//      print(globalVar.userId,globalVar.userPass)
      loginUser()
    }
  }
  
  func loginUser(){
    let str = "user_id=\(globalVar.userId)&user_pass=\(globalVar.userPass)"
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
          self.testRealm()
          print("出力",strData)
          self.getUser(token: strData)
          
        }
      }
    }.resume()
  }
  
  func getUser(token : String){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/find?user_id=\(globalVar.userId)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let allData = try? JSONDecoder().decode(AllData.self, from: data)
        if(allData!.status == 200){
          print("名前!!!!",(allData?.record![0].userName)!)
          self.saveUser(id: self.globalVar.userId, pass: self.globalVar.userPass, token: token, name: (allData?.record![0].userName)!, generation:  (allData?.record![0].generation)!, gender:  (allData?.record![0].gender)!, header:  (allData?.record![0].userHeader ?? "http:/api.mino.asia:8080/test1/netherland-1-860x573.jpg"), icon:  (allData?.record![0].userIcon)!, comment:  (allData?.record![0].comment)!)
          self.globalVar.token = token
          self.globalVar.userName = (allData?.record![0].userName)!
          self.settingData(gender: (allData?.record![0].gender)!, generation: (allData?.record![0].generation)!)
          self.globalVar.userComment = (allData?.record![0].comment)!
          self.globalVar.userIconPath = (allData?.record![0].userIcon)!
          self.globalVar.userHeaderPath = (allData?.record![0].userHeader ?? "http://api.mino.asia:8080/test1/netherland-1-860x573.jpg")
          self.performSegue(withIdentifier: "toStartView", sender: nil)
        }
      }
    }.resume()
  }
  struct AllData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let userId : String
      let userName : String
      let generation : Int
      let gender : String
      let comment : String?
      let userIcon : String?
      let userHeader : String?
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case generation = "generation"
        case gender = "gender"
        case comment = "comment"
        case userIcon = "user_icon"
        case userHeader = "user_header"
        case date
      }
    }
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
  
  func saveUser(id : String, pass : String, token : String, name : String, generation : Int, gender : String, header : String, icon : String, comment : String){
    let realm = try! Realm()
    let userModel = UserModel()
    
    let users = realm.objects(UserModel.self)
    
    for _user in users{
      try! realm.write() {
        realm.delete(_user)
      }
    }
    
  print("saveUser名前",name)
    
    userModel.user_id = id
    userModel.user_pass = pass
    userModel.user_comment = comment
    userModel.user_token = token
    userModel.user_name = name
    userModel.user_image = icon
    userModel.user_generation = generation
    userModel.user_gender = gender
    userModel.user_header = header
    
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
      print("generation", _user.user_generation)
    }
  }
  func settingData(gender:String,generation:Int){
    switch gender {
    case "男":
      globalVar.userGender = "男性"
      break
    case "女":
      globalVar.userGender = "女性"
      break
    default:
      break
    }
    switch generation {
    case 0:
      globalVar.userGeneration = "10歳未満"
      break
    case 10:
      globalVar.userGeneration = "10代"
      break
    case 20:
      globalVar.userGeneration = "20代"
      break
    case 30:
      globalVar.userGeneration = "30代"
      break
    case 40:
      globalVar.userGeneration = "40代"
      break
    case 50:
      globalVar.userGeneration = "50代"
      break
    case 60:
      globalVar.userGeneration = "60代"
      break
    case 70:
      globalVar.userGeneration = "70代"
      break
    case 80:
      globalVar.userGeneration = "80代"
      break
    case 90:
      globalVar.userGeneration = "90代"
      break
    case 100:
      globalVar.userGeneration = "100歳以上"
      break
    default:
      break
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
