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
          self.getTimeline(offset: 0)
          self.searchTimeline(offset: 0, generation:  (allData?.record![0].generation)!)
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.performSegue(withIdentifier: "toStartView", sender: nil)
          }
        }
      }
    }.resume()
  }
  
  struct TimelineData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let planId : Int
      let userId : String
      let planTitle : String
      let planComment : String?
      let transportation : String
      let price : String
      let area : String
      let planDate : String
      let user : User
      let spots : [Spots]
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case userId = "user_id"
        case planTitle = "plan_title"
        case planComment = "plan_comment"
        case transportation = "transportation"
        case price = "price"
        case area = "area"
        case planDate = "plan_date"
        case user = "user"
        case spots = "spots"
        case date
      }
      struct User : Codable{
        let userName : String
        let userIcon : String?
        enum CodingKeys: String, CodingKey {
          case userName = "user_name"
          case userIcon = "user_icon"
        }
      }
      struct Spots : Codable{
        let spotId : Int
        let spotTitle : String
        let spotImageA : String?
        let spotImageB : String?
        let spotImageC : String?
        enum CodingKeys: String, CodingKey {
          case spotId = "spot_id"
          case spotTitle = "spot_title"
          case spotImageA = "spot_image_a"
          case spotImageB = "spot_image_b"
          case spotImageC = "spot_image_c"
        }
      }
    }
  }
  func getTimeline(offset:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/timeline/find?offset=\(offset)&limit=3")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let timelineData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(timelineData!.status == 200){
          for i in 0 ... 2{
            var count = 0
            self.globalVar.newPlanIdList.append((timelineData?.record![i].planId)!)
            self.globalVar.newUserIdList.append((timelineData?.record![i].userId)!)
            self.globalVar.newPlanTitleList.append((timelineData?.record![i].planTitle)!)
            self.globalVar.newUserNameList.append((timelineData?.record![i].user.userName)!)
            self.globalVar.newPlanAreaList.append((timelineData?.record![i].area)!)
            self.globalVar.newPlanTransportationList.append((timelineData?.record![i].transportation)!)
            self.globalVar.newPlanPriceList.append((timelineData?.record![i].price)!)
            self.globalVar.newPlanCommentList.append((timelineData?.record![i].planComment)!)
            
            if(timelineData?.record![i].user.userIcon != ""){
              let url = URL(string: (timelineData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.newUserImageList.append(image!)
            }else{
              self.globalVar.newUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (timelineData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.globalVar.newDateList.append("\(date)日")
            
            for f in 0 ... (timelineData?.record![i].spots.count)! - 1{
              if((timelineData?.record![i].spots[f].spotImageA)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageA)!)
              }else if((timelineData?.record![i].spots[f].spotImageB)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageB)!)
              }else if((timelineData?.record![i].spots[f].spotImageC)! != ""){
                self.globalVar.newSpotImagePathList?.append((timelineData?.record![i].spots[f].spotImageC)!)
              }
              if(f == 0){
                self.globalVar.newSpotNameListA.append((timelineData?.record![i].spots[f].spotTitle)!)
                self.globalVar.newSpotNameListB?.append("")
              }else if(f == 1){
                self.globalVar.newSpotNameListB?.insert((timelineData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.globalVar.newSpotCountList.append(count)
            self.globalVar.newSpotImagePathList?.append("")
            self.globalVar.newTrueSpotImagePathList?.append(self.globalVar.newSpotImagePathList![0])
            if(self.globalVar.newTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.globalVar.newTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.newSpotImageList?.append(image!)
            }else{
              self.globalVar.newSpotImageList?.append(UIImage(named: "no-image.png")!)
            }
            self.globalVar.newSpotImagePathList?.removeAll()
            self.globalVar.newPlanCount += 1
          }
        }
      }else{
      }
      }.resume()
  }
  
  
  func searchTimeline(offset:Int,generation:Int){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/search/find?generation=\(generation)&limit=3")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let searchData = try? JSONDecoder().decode(TimelineData.self, from: data)
        if(searchData!.status == 200){
          for i in 0 ... 2{
            var count = 0
            self.globalVar.searchPlanIdList.append((searchData?.record![i].planId)!)
            self.globalVar.searchUserIdList.append((searchData?.record![i].userId)!)
            self.globalVar.searchPlanTitleList.append((searchData?.record![i].planTitle)!)
            self.globalVar.searchUserNameList.append((searchData?.record![i].user.userName)!)
            self.globalVar.searchPlanAreaList.append((searchData?.record![i].area)!)
            self.globalVar.searchPlanTransportationList.append((searchData?.record![i].transportation)!)
            self.globalVar.searchPlanPriceList.append((searchData?.record![i].price)!)
            self.globalVar.searchPlanCommentList.append((searchData?.record![i].planComment)!)
            if(searchData?.record![i].user.userIcon != ""){
              let url = URL(string: (searchData?.record![i].user.userIcon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.searchUserImageList.append(image!)
            }else{
              self.globalVar.searchUserImageList.append(UIImage(named: "no-image.png")!)
            }
            let planDate = (searchData?.record![i].planDate)!.prefix(10)
            var date = planDate.suffix(5)
            if let range = date.range(of: "-"){
              date.replaceSubrange(range, with: "月")
            }
            self.globalVar.searchDateList.append("\(date)日")
            for f in 0 ... (searchData?.record![i].spots.count)! - 1{
              if((searchData?.record![i].spots[f].spotImageA)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageA)!)
              }else if((searchData?.record![i].spots[f].spotImageB)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageB)!)
              }else if((searchData?.record![i].spots[f].spotImageC)! != ""){
                self.globalVar.searchSpotImagePathList?.append((searchData?.record![i].spots[f].spotImageC)!)
              }
              if(f == 0){
                self.globalVar.searchSpotNameListA.append((searchData?.record![i].spots[f].spotTitle)!)
                self.globalVar.searchSpotNameListB?.append("")
              }else if(f == 1){
                self.globalVar.searchSpotNameListB?.insert((searchData?.record![i].spots[f].spotTitle)!, at: i)
              }else if(f > 1){
                count += 1
              }
            }
            self.globalVar.searchSpotCountList.append(count)
            self.globalVar.searchSpotImagePathList?.append("")
            self.globalVar.searchTrueSpotImagePathList?.append(self.globalVar.searchSpotImagePathList![0])
            if(self.globalVar.searchTrueSpotImagePathList![i] != ""){
              let url = URL(string: self.globalVar.searchTrueSpotImagePathList![i])!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.globalVar.searchSpotImageList?.append(image!)
            }else{
              self.globalVar.searchSpotImageList?.append(UIImage(named: "no-image.png")!)
            }
            self.globalVar.searchSpotImagePathList?.removeAll()
            self.globalVar.searchPlanCount += 1
          }
        }
      }else{
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
