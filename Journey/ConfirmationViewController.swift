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
  
  let ipAddress = "192.168.100.102:3000"
  //  let ipAddress = "35.200.26.70:443"
  
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
  

  func postImage(){
    let imageData = setIconImageView.image?.jpegData(compressionQuality: 1.0)
    let body = httpBody(imageData!, fileName: "\(globalVar.userId).jpg")
    let url = URL(string: "http://\(ipAddress)/api/v1/image/upload")!
    fileUpload(url, data: body) {(data, response, error) in
      if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
        if response.statusCode == 200 {
          print("Upload done",data as Any)
          print(String(data: data!, encoding: .utf8) ?? "")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
