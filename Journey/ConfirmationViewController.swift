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
  //var pickedImage: UIImage? //選択されたイメージを保存するためのインスタンス変数
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  
  let ipAddress = "172.20.10.2:3000"
  //  let ipAddress = "35.200.26.70:443"
  var gender:String = ""
  var generation:Int = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      userIdLabel.text = globalVar.userId
      userNameLabel.text = globalVar.userName
      userGenerationLabel.text = globalVar.userGeneration
      userGenderLabel.text = globalVar.userGender
      setIconImageView.image = globalVar.userIcon
      settingData()
        // Do any additional setup after loading the view.
    }
  @IBAction func tappedModificationButton(_ sender: Any) {
    performSegue(withIdentifier: "backCreateUserView", sender: nil)
  }
  @IBAction func tappedStartViewButton(_ sender: Any) {
    postImage()
    self.performSegue(withIdentifier: "toStartView", sender: nil)
  }
  

  func postImage(){
    let imageData = setIconImageView.image?.jpegData(compressionQuality: 1.0)
    let body = httpBody(imageData!, fileName: "\(globalVar.userId).jpg")
    let url = URL(string: "http://\(ipAddress)/api/v1/image/upload")!
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
    let str = "user_id=\(globalVar.userId)&user_pass=\(globalVar.userPass)&user_name=\(globalVar.userName)&generation=\(generation)&gender=\(gender)&comment=こんにちは&user_icon=\(imageStr)"
    let url = URL(string: "http://\(ipAddress)/api/v1/users/register")
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
      }
    }.resume()
  }
  
  func settingData(){
    switch globalVar.userGender {
    case "男性":
      gender = "男"
      break
    case "女性":
      gender = "女"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
