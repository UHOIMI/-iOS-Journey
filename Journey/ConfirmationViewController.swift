//
//  ConfirmationViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/22.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class ConfirmationViewController: UIViewController {
  
  @IBOutlet weak var setIconImageView: UIImageView!
  @IBOutlet weak var userIdLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userGenerationLabel: UILabel!
  @IBOutlet weak var userGenderLabel: UILabel!
  
  let globalVar = GlobalVar.shared
  //var pickedImage: UIImage? //選択されたイメージを保存するためのインスタンス変数
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  
  let ipAddress = "172.20.10.2:3000"
  //  let ipAddress = "api.mino.asia:443"
  var gender:String = ""
  var generation:Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationItem.hidesBackButton = true
      
      userIdLabel.text = globalVar.userId
      userNameLabel.text = globalVar.userName
      userGenerationLabel.text = globalVar.userGeneration
      userGenderLabel.text = globalVar.userGender
      setIconImageView.image = globalVar.userIcon
      settingData()
      
      self.setIconImageView.layer.cornerRadius = 100 * 0.5
      self.setIconImageView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
  @IBAction func tappedModificationButton(_ sender: Any) {
    performSegue(withIdentifier: "backCreateUserView", sender: nil)
  }
  @IBAction func tappedStartViewButton(_ sender: Any) {
    postImage()
//    saveUser(id: globalVar.userId, name: globalVar.userName, pass: globalVar.userPass, generation: generation, gender: globalVar.userGender)
//    self.performSegue(withIdentifier: "toStartView", sender: nil)
  }
  

  func postImage(){
    let imageData = setIconImageView.image?.jpegData(compressionQuality: 1.0)
    let body = httpBody(imageData!, fileName: "\(globalVar.userId).jpg")
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/image/upload")!
    fileUpload(url, data: body) {(data, response, error) in
      if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
        if response.statusCode == 200 {
          var imageStr:String = String(data: data!, encoding: .utf8)!
          if let range = imageStr.range(of: "["){
            imageStr.removeSubrange(range)
          }
          for _ in 0...1{
            if let range = imageStr.range(of: "\\"){
              imageStr.removeSubrange(range)
            }
            if let range = imageStr.range(of: "\""){
              imageStr.removeSubrange(range)
            }
          }
          if let range = imageStr.range(of: "]"){
            imageStr.removeSubrange(range)
          }
          print("Upload done",data as Any)
          print(String(data: data!, encoding: .utf8) ?? "")
          self.postUser(imageStr: imageStr)
        } else {
          print(response.statusCode)
        }
      }
    }
  }
  func httpBody(_ fileAsData: Data, fileName: String) -> Data {
    var data = "--\(boundary)\r\n".data(using: .utf8)!
    // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
    data += "Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
    data += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
    data += "\r\n".data(using: .utf8)!
    data += fileAsData
    data += "\r\n".data(using: .utf8)!
    data += "--\(boundary)--\r\n".data(using: .utf8)!
    
    return data
  }
  // リクエストを生成してアップロード
  func fileUpload(_ url: URL, data: Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // マルチパートでファイルアップロード
    let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    let urlConfig = URLSessionConfiguration.default
    urlConfig.httpAdditionalHeaders = headers
    
    let session = Foundation.URLSession(configuration: urlConfig)
    let task = session.uploadTask(with: request, from: data, completionHandler: completionHandler)
    task.resume()
  }
  
  func postUser(imageStr:String){
    print("imageStr",imageStr)
    let imgPath = "http://api.mino.asia:8080/test1/\(imageStr)"
    let str = "user_id=\(globalVar.userId)&user_pass=\(globalVar.userPass)&user_name=\(globalVar.userName)&generation=\(generation)&gender=\(gender)&comment=こんにちは&user_icon=\(imgPath)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/register")
    var request = URLRequest(url: url!)
    // POSTを指定
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
          self.saveUser(id: self.globalVar.userId, name: self.globalVar.userName, pass: self.globalVar.userPass, generation: self.generation, gender:  self.gender, token: strData, icon: imgPath)
          print("出力",strData)
          self.globalVar.token = strData
          self.getTimeline(offset: 0)
          self.searchTimeline(offset: 0, generation:  self.generation)
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
  
  func settingData(){
    switch globalVar.userGender {
    case "男性":
      gender = "男性"
      break
    case "女性":
      gender = "女性"
      break
    default:
      break
    }
    switch globalVar.userGeneration {
    case "10歳未満":
      generation = 0
      break
    case "10代":
      generation = 10
      break
    case "20代":
      generation = 20
      break
    case "30代":
      generation = 30
      break
    case "40代":
      generation = 40
      break
    case "50代":
      generation = 50
      break
    case "60代":
      generation = 60
      break
    case "70代":
      generation = 70
      break
    case "80代":
      generation = 80
      break
    case "90代":
      generation = 90
      break
    case "100歳以上":
      generation = 100
      break
    default:
      break
    }
  }
  
  func saveUser(id : String, name : String, pass : String, generation : Int, gender : String, token : String, icon : String){
    let realm = try! Realm()
    let userModel = UserModel()
    let users = realm.objects(UserModel.self)
    for _user in users{
      try! realm.write() {
        realm.delete(_user)
      }
    }
    
    userModel.user_id = id
    userModel.user_name = name
    userModel.user_pass = pass
    userModel.user_generation = generation
    userModel.user_gender = gender
    userModel.user_comment = "こんにちは"
    userModel.user_header = "http://api.mino.asia:8080/test1/netherland-1-860x573.jpg"
    userModel.user_image = icon
    userModel.user_token = token
    globalVar.userComment = "こんにちは"
    globalVar.userIconPath = icon
    globalVar.userHeaderPath = "http://api.mino.asia:8080/test1/netherland-1-860x573.jpg"
    
    try! realm.write() {
      realm.add(userModel, update: true)
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
