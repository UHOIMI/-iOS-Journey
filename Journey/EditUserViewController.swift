//
//  EditUserViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/07.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RSKImageCropper
import Photos
import Realm
import RealmSwift

class EditUserViewController: UIViewController ,UITabBarDelegate, UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var imgView:UIImageView!
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
  private var tabBar:TabBar!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var headerImageView: UIImageView!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var userGenerationTextField: UITextField!
  @IBOutlet weak var userPassLabel: UILabel!
  @IBOutlet weak var userCommentTextView: UITextView!
  
  let globalVar = GlobalVar.shared
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  var generation:Int = 0
  var editImage : UIImage? = nil
  var editImageNum = 1
  var iconFlag = 0
  var headerFlag = 0
  let generationList = ["-年代を選択-","10歳未満","10代","20代","30代","40代","50代","60代","70代","80代","90代","100歳以上"]
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return generationList.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return generationList[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      userGenerationTextField.text = generationList[row]
  }
    override func viewDidLoad() {
      
      print("token",globalVar.token)
        super.viewDidLoad()
      
      let generationPickerView = UIPickerView()
      generationPickerView.tag = 1
      generationPickerView.delegate = self
      userGenerationTextField.inputView = generationPickerView
      
      if myFrameSize.height >= 812{
        //scrollViewsetScrollEnabled
        scrollView.isScrollEnabled = false
      }
      
      if(globalVar.userHeaderPath == "" || globalVar.userHeaderPath == "nil"){
        headerImageView.image = UIImage(named: "mountain")
      }else{
        let url = URL(string: globalVar.userHeaderPath)!
        let imageData = try? Data(contentsOf: url)
        let image = UIImage(data:imageData!)
        headerImageView.image = image
      }
      if(globalVar.userIconPath == ""){
        imgView.image = UIImage(named: "no-image.png")
        self.imgView = UIImageView()
        imgView.frame = CGRect(x: 30, y: headerImageView.frame.origin.y + (UIScreen.main.bounds.size.width / 3), width: 100, height: 100)
        imgView.frame.origin.y -= self.imgView.frame.height / 2
      }else{
        let iconUrl = URL(string: globalVar.userIconPath)!
        let iconData = try? Data(contentsOf: iconUrl)
        let iconImage = UIImage(data:iconData!)
        self.imgView = UIImageView()
        imgView.frame = CGRect(x: 30, y: headerImageView.frame.origin.y + (UIScreen.main.bounds.size.width / 3), width: 100, height: 100)
        imgView.image = iconImage
        imgView.frame.origin.y -= self.imgView.frame.height / 2
      }
      
      // 角を丸くする
      self.imgView.layer.cornerRadius = 100 * 0.5
      self.imgView.clipsToBounds = true
      imgView.isUserInteractionEnabled = true
      imgView.tag = 1
      
      subView.addSubview(self.imgView)
      
      userNameTextField.text = globalVar.userName
      userPassLabel.text = String(globalVar.userPass.suffix(4))
      userGenerationTextField.text = globalVar.userGeneration
      userCommentTextView.text = globalVar.userComment
      
      userCommentTextView.layer.borderColor = UIColor.gray.cgColor
      userCommentTextView.layer.borderWidth = 0.5
      userCommentTextView.layer.cornerRadius = 10.0
      userCommentTextView.layer.masksToBounds = true

      keyboardSettings()
      createTabBar()
        // Do any additional setup after loading the view.
    }
  
  @objc func commitButtonTapped (){
    self.view.endEditing(true)
    self.resignFirstResponder()
  }
  
  func postImage(setImage:UIImage){
    let imageData = setImage.jpegData(compressionQuality: 1.0)
    let body = httpBody(imageData!, fileName: "\(globalVar.userId).jpg")
    let url = URL(string: "http://35.200.26.70:443/api/v1/image/upload")!
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
          if(self.iconFlag == 1){
            self.iconFlag = 0
            self.globalVar.userIconPath = "http://35.200.26.70:8080/test1/\(imageStr)"
          }else if(self.headerFlag == 1){
            self.headerFlag = 0
            self.globalVar.userHeaderPath = "http://35.200.26.70:8080/test1/\(imageStr)"
          }
          if(self.iconFlag == 0 && self.headerFlag == 0){
            self.updateUser()
          }
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
  
  func updateUser(){
    let str = "user_name=\(userNameTextField.text!)&generation=\(generation)&comment=\(userCommentTextView.text!)&user_icon=\(globalVar.userIconPath)&user_header=\(globalVar.userHeaderPath)&token=\(globalVar.token)"
    print("表示",str)
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/update")
    var request = URLRequest(url: url!)
    // POSTを指定
    request.httpMethod = "PUT"
    // POSTするデータをBodyとして設定
    request.httpBody = str.data(using: .utf8)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: .utf8) ?? "")
        self.saveUser(name: self.globalVar.userName, generation: self.generation, icon: self.globalVar.userIconPath, header: self.globalVar.userHeaderPath, comment: self.globalVar.userComment)
        self.performSegue(withIdentifier: "backDetaileUserView", sender: nil)
      }
    }.resume()
  }
  
  func settingData(userGeneration : String){
    switch userGeneration {
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch: UITouch in touches {
      let tag = touch.view!.tag
      switch (tag) {
      case 1:
        setImage(num: 1)
        break
      case 2:
        setImage(num: 2)
        break
      default:
        break
      }
    }
  }
  
  func setImage(num : Int) {
    editImageNum = num
    checkPermission()
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      let ipc = UIImagePickerController()
      ipc.delegate = self
      ipc.sourceType = UIImagePickerController.SourceType.photoLibrary
      ipc.allowsEditing = false
      self.present(ipc,animated: true)
    }
  }
  
  func cutImage(image : UIImage){
    var imageCropVC = RSKImageCropViewController(image: image, cropMode: .square)
    if(editImageNum == 2){
      imageCropVC = RSKImageCropViewController(image: image, cropMode: .custom)
      imageCropVC.dataSource = self
    }
    imageCropVC.moveAndScaleLabel.text = "切り取り範囲を選択"
    imageCropVC.cancelButton.setTitle("キャンセル", for: .normal)
    imageCropVC.chooseButton.setTitle("完了", for: .normal)
    imageCropVC.delegate = self
    present(imageCropVC, animated: true)
  }
  
  func checkPermission(){
    let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
    
    switch photoAuthorizationStatus {
    case .authorized:
      print("auth")
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({
        (newStatus) in
        print("status is \(newStatus)")
        if newStatus ==  PHAuthorizationStatus.authorized {
          /* do stuff here */
          print("success")
        }
      })
      print("not Determined")
    case .restricted:
      print("restricted")
    case .denied:
      print("denied")
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
    editImage = image
    
    dismiss(animated: true, completion: {
      self.cutImage(image: self.editImage!)
    })
  }
  
  @IBAction func tappedSaveButton(_ sender: Any) {
    if(userNameTextField.text == ""){
      showAlert(title: "ユーザー名が入力されていません", message: "ユーザー名を入力してください")
    }else if((userNameTextField.text?.count)! > 20){
      showAlert(title: "ユーザー名が20文字を超えています", message: "文字数を20文字以内にしてください")
    }else if(userGenerationTextField.text == "" || userGenerationTextField.text == "-年代を選択-"){
      showAlert(title: "年代が選択されていません", message: "年代を選択してください")
    }else if((userCommentTextView.text?.count)! > 200){
      showAlert(title: "コメントが200文字を超えています", message: "文字数を200文字以内にしてください")
    }
  
    settingData(userGeneration: userGenerationTextField.text!)
    globalVar.userName = userNameTextField.text!
    globalVar.userGeneration = userGenerationTextField.text!
    globalVar.userComment = userCommentTextView.text
    if(iconFlag == 1){
      postImage(setImage: imgView.image!)
    }
    if(headerFlag == 1){
      postImage(setImage: headerImageView.image!)
    }
    if(iconFlag == 0 && headerFlag == 0){
      updateUser()
    }
  }
  @IBAction func tappedShowPasswordButton(_ sender: Any) {
    let ac = UIAlertController(title: "パスワード表示", message: "ユーザーIDを入力してください", preferredStyle: .alert)
    let ok = UIAlertAction(title: "表示", style: .default, handler: {[weak ac] (action) -> Void in
      guard let textFields = ac?.textFields else {
        return
      }
      guard !textFields.isEmpty else {
        return
      }
      for text in textFields {
        if text.tag == 1 {
          if(text.text! == self.globalVar.userId){
            self.showAlert(title: "パスワード表示", message: self.globalVar.userPass)
          }else{
            self.showAlert(title: "ユーザーIDが間違っています", message: "入力し直してください")
          }
        }
      }
    })
    let cancel = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
    
    //textfiled1の追加
    ac.addTextField(configurationHandler: {(text:UITextField!) -> Void in
      text.tag  = 1
      text.placeholder = "ユーザーID"
    })
    
    ac.addAction(ok)
    ac.addAction(cancel)
    
    present(ac, animated: true, completion: nil)
  }
  
  @IBAction func tappedCancelButton(_ sender: Any) {
    performSegue(withIdentifier: "backDetailUserView", sender: nil)
  }
  func showAlert(title:String,message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let cancelButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
    alert.addAction(cancelButton)
    self.present(alert, animated: true, completion: nil)
  }
  
  func keyboardSettings(){
    // 仮のサイズでツールバー生成
    let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
    kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
    kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
    // スペーサー
    let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
    // 閉じるボタン
    let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.commitButtonTapped))
    kbToolBar.items = [spacer, commitButton]
    userCommentTextView.inputAccessoryView = kbToolBar
  }
  
  // キーボードが現れた時に、画面全体をずらす。
  @objc func keyboardWillShow(notification: Notification?) {
    tabBar.isHidden = true
    let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    UIView.animate(withDuration: duration!, animations: { () in
      let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
      self.view.transform = transform
      
    })
  }
  
  // キーボードが消えたときに、画面を戻す
  @objc func keyboardWillHide(notification: Notification?) {
    tabBar.isHidden = false
    let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
    UIView.animate(withDuration: duration!, animations: { () in
      
      self.view.transform = CGAffineTransform.identity
    })
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
    return true
  }
  
  func createTabBar(){
    let width = self.view.frame.width
    let height = self.view.frame.height
    //デフォルトは49
    let tabBarHeight:CGFloat = 58
    /**   TabBarを設置   **/
    tabBar = TabBar()
    if UIDevice().userInterfaceIdiom == .phone {
      switch UIScreen.main.nativeBounds.height {
      case 2436:
        tabBar.frame = CGRect(x:0,y:height - tabBarHeight - 34.1,width:width,height:tabBarHeight)
      default:
        tabBar.frame = CGRect(x:0,y:height - tabBarHeight,width:width,height:tabBarHeight)
      }
    }
    //バーの色
    tabBar.barTintColor = UIColor.lightGray
    //選択されていないボタンの色
    tabBar.unselectedItemTintColor = UIColor.black
    //ボタンを押した時の色
    tabBar.tintColor = UIColor.black
    //ボタンを生成
    let home:UITabBarItem = UITabBarItem(title: "home", image: UIImage(named:"home.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 1)
    let search:UITabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
    let favorites:UITabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
    let setting:UITabBarItem = UITabBarItem(title: "setting", image: UIImage(named:"settings.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 4)
    //ボタンをタブバーに配置する
    tabBar.items = [home,search,favorites,setting]
    //デリゲートを設定する
    tabBar.delegate = self
    
    self.view.addSubview(tabBar)
  }
  
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    switch item.tag{
    case 1:
      print("１")
    case 2:
      print("２")
    case 3:
      print("３")
    case 4:
      performSegue(withIdentifier: "backDetailUserView", sender: nil)
    default : return
      
    }
  }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
  return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}

extension EditUserViewController: RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
  
  func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
    
    print("マスク")
    
    var maskSize: CGSize
    var width, height: CGFloat!
    
    width = self.view.frame.width
    print(width)
    
    // 縦横比 = 1 : 2でトリミングしたい場合
    height = self.view.frame.width / 3
    print(height)
    
    maskSize = CGSize(width: width, height: height)
    
    let viewWidth: CGFloat = controller.view.frame.width
    let viewHeight: CGFloat = controller.view.frame.height
    
    let maskRect: CGRect = CGRect(x: (viewWidth - maskSize.width) * 0.5, y: (viewHeight - maskSize.height) * 0.5, width: maskSize.width, height: maskSize.height)
    print(maskRect)
    return maskRect
  }
  
  func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
    
    print("マスク２")
    
    let rect: CGRect = controller.maskRect
    print(rect)
    
    let point1: CGPoint = CGPoint(x: rect.minX, y: rect.maxY)
    let point2: CGPoint = CGPoint(x: rect.maxX, y: rect.maxY)
    let point3: CGPoint = CGPoint(x: rect.maxX, y: rect.minY)
    let point4: CGPoint = CGPoint(x: rect.minX, y: rect.minY)
    
    print(point1)
    print(point2)
    print(point3)
    print(point4)
    
    let square: UIBezierPath = UIBezierPath()
    square.move(to: point1)
    square.addLine(to: point2)
    square.addLine(to: point3)
    square.addLine(to: point4)
    square.close()
    
    return square
  }
  
  func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
    return controller.maskRect
  }
  
  //キャンセルを押した時の処理
  func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
    dismiss(animated: true, completion: nil)
  }
  //完了を押した後の処理
  func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
    
    dismiss(animated: true)
    
    if controller.cropMode == .square {
      iconFlag = 1
      imgView.image = croppedImage
    }else if controller.cropMode == .custom{
      headerImageView.image = croppedImage
      headerFlag = 1
    }
  }
  func saveUser(name : String,generation : Int, icon : String, header:String, comment:String){
    let realm = try! Realm()
    let userModel = UserModel()
    let users = realm.objects(UserModel.self)
    for _user in users{
      try! realm.write() {
        realm.delete(_user)
      }
    }
    userModel.user_name = name
    userModel.user_generation = generation
    userModel.user_comment = comment
    userModel.user_header = header
    userModel.user_image = icon
    
    try! realm.write() {
      realm.add(userModel, update: true)
    }
  }
}
