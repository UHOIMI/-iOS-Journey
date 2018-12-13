//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation
import Photos
import CoreLocation
import CoreMotion
import RealmSwift

class PostViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate,UITabBarDelegate,UITextFieldDelegate,UITextViewDelegate{

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var spotTable: UITableView!
  @IBOutlet weak var tableHeight: NSLayoutConstraint!
  @IBOutlet weak var pickerTextField: UITextField!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var subViewHeight: NSLayoutConstraint!
  @IBOutlet weak var prefecturesTextField: UITextField!
  
  var height = 46
  var viewHeight = 1000
  var pickOption = ["500円以下", "501円 ~ 1000円", "1001円 ~ 5000円", "5001円 ~ 10000円", "10001円 ~ 20000円", "20001円 ~ 50000円", "50001円以上"]
  let prefectures:Array = [ "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県", "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県", "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県", "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県","鳥取県", "島根県", "岡山県", "広島県", "山口県","徳島県", "香川県", "愛媛県", "高知県", "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県"]
 
  var transportation = ["0,","0,","0,","0,","0,","0,","0"]
  var spotData : ListSpotModel = ListSpotModel()
  
  var imageFlag1 = 0
  var imageFlag2 = 0
  var imageFlag3 = 0
  var imageFlag4 = 0
  var imageFlag5 = 0
  var imageFlag6 = 0
  var imageFlag7 = 0
  
  let spotFlagList = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t"]
  var spotList : [Int] = []
  var postSpotCount = 0
  
  let color = UIColor.blue
  
  var camera = GMSCameraPosition.camera(withLatitude: 35.710063,longitude:139.8107, zoom:15)

  var makerList : [GMSMarker] = []
  
  var globalVar = GlobalVar.shared
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  private var tabBar:TabBar!
  
  var pickedImageA: UIImage?
  var pickedImageB: UIImage?
  var pickedImageC: UIImage?
  let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
  
  var imageCount = 0
  var setImageCount = 0
  var imageFlagList = Array(repeating:0, count:60)
  var imageNumber = 0
  var setPlanId = 0
  
  var imageA = ""
  var imageB = ""
  var imageC = ""
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 1{
      return prefectures.count
    }else{
      return pickOption.count
    }
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 1{
      return prefectures[row]
    }else{
      return pickOption[row]
    }
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 1{
      prefecturesTextField.text = prefectures[row]
    }else{
      pickerTextField.text = pickOption[row]
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return(globalVar.selectSpot.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
    if(indexPath.row == 0){
      cell.textLabel?.text = globalVar.selectSpot[indexPath.row]
    }else{
      cell.textLabel?.text = String(indexPath.row) + " : " + globalVar.selectSpot[indexPath.row]
    }
    
    return(cell)
  }
  
  func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
    let selectedNumber = globalVar.selectSpot[indexPath.row]
    if(selectedNumber == "スポットを追加" && globalVar.selectSpot.count < 21){
      globalVar.planTitle = titleTextField.text!
      globalVar.planArea = prefecturesTextField.text!
      globalVar.planPrice = pickerTextField.text!
      globalVar.planText = textView.text!
      performSegue(withIdentifier: "toSelectSpotView", sender: nil)
    }else if(selectedNumber == "スポットを追加" && globalVar.selectSpot.count >= 21){
      globalVar.selectSpot[0] = "これ以上追加できません"
      spotTable.reloadData()
    }else{
      let selectedModel = globalVar.spotDataList[indexPath.row - 1]
      performSegue(withIdentifier: "toDetailSpotView", sender: selectedModel)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "toDetailSpotView"){
      let nextView = segue.destination as! DetailSpotViewController
      nextView.spotData = sender as! ListSpotModel
    }
  }
  
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
      self.globalVar.selectSpot.remove(at: indexPath.row)
      self.globalVar.spotDataList.remove(at: indexPath.row - 1)
      if(self.globalVar.spotDataList.count != 0){
        self.camera = GMSCameraPosition.camera(withLatitude: self.globalVar.spotDataList[0].latitude,longitude:self.globalVar.spotDataList[0].longitude, zoom:15)
      }
      let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:0,width:self.myFrameSize.width,height:300),camera:self.camera)
      if(self.globalVar.spotDataList.count != 0){
        for i in 0 ... self.globalVar.spotDataList.count - 1{
          self.makerList.append(GMSMarker())
          self.makerList[i].position = CLLocationCoordinate2D(latitude: self.globalVar.spotDataList[i].latitude, longitude: self.globalVar.spotDataList[i].longitude)
          self.makerList[i].map = mapView
        }
      }
      self.subView.addSubview(mapView)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.height -= 43
      self.tableHeight.constant = CGFloat(self.height)
      self.globalVar.selectSpot[0] = "スポットを追加"
      self.globalVar.selectCount -= 1
      self.spotTable.reloadData()
      self.viewHeight -= 43
      self.subViewHeight.constant = CGFloat(self.viewHeight)
      self.subView.frame = CGRect(x:0, y: 0, width:375, height:self.viewHeight)
    }
    deleteButton.backgroundColor = UIColor.red
    return [deleteButton]
  }

  func updateTableView(name:String, list:ListSpotModel) {
    globalVar.selectSpot.append(name)
    globalVar.spotDataList.append(list)
    print(globalVar.selectSpot)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    idSetRealm()
    
    if(globalVar.spotDataList.count != 0){
      camera = GMSCameraPosition.camera(withLatitude: globalVar.spotDataList[0].latitude,longitude:globalVar.spotDataList[0].longitude, zoom:15)
    }
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:0,width:myFrameSize.width,height:300),camera:camera)
    if(globalVar.spotDataList.count != 0){
      for i in 0 ... globalVar.spotDataList.count - 1{
        makerList.append(GMSMarker())
        makerList[i].position = CLLocationCoordinate2D(latitude: globalVar.spotDataList[i].latitude, longitude: globalVar.spotDataList[i].longitude)
        makerList[i].map = mapView
      }
    }
    self.subView.addSubview(mapView)
    if(globalVar.planTitle != ""){
      titleTextField.text = globalVar.planTitle
    }else{
      titleTextField.placeholder = "プラン名を入力"
    }
    if(globalVar.planArea != ""){
      prefecturesTextField.text = globalVar.planArea
    }else{
      prefecturesTextField.placeholder = "都道府県を選択してください"
    }
    if(globalVar.planPrice != ""){
      pickerTextField.text = globalVar.planPrice
    }else{
      pickerTextField.placeholder = "金額を選択してください"
    }
    if(globalVar.planText != ""){
      textView.text = globalVar.planText
    }else{
      textView.text = ""
    }
    spotTable.delegate = self
    spotTable.dataSource = self
    tableHeight.constant = CGFloat(height)
    
    let prefecturesPickerView = UIPickerView()
    prefecturesPickerView.tag = 1
    prefecturesPickerView.delegate = self
    prefecturesTextField.inputView = prefecturesPickerView
    
    let pickerView = UIPickerView()
    pickerView.tag = 2
    pickerView.delegate = self
    pickerTextField.inputView = pickerView
    
    textView.delegate = self
    titleTextField.delegate = self
    
    textViewSetteings()
    keyboardSettings()
    createTabBar()
    if(globalVar.selectSpot.count != 1){
      for _ in globalVar.selectSpot{
        height += 43
        tableHeight.constant = CGFloat(height)
        spotTable.reloadData()
        viewHeight = viewHeight + 43
      }
    }
    subViewHeight.constant = CGFloat(viewHeight)
    subView.frame = CGRect(x:0, y: 0, width:375, height:viewHeight)
  }
  func showAlert(title:String,message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let cancelButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
    alert.addAction(cancelButton)
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func tappedPostButton(_ sender: Any) {
    let transportationString = transportation.reduce("") { $0 + String($1) }
    if(titleTextField.text! == ""){
      showAlert(title: "プラン名が入力されていません", message: "プラン名を入力してください")
    }else if((titleTextField.text?.count)! >= 21){
      showAlert(title: "プラン名が20文字を超えています", message: "文字数を20文字以内にしてください")
    }else if(prefecturesTextField.text == ""){
      showAlert(title: "都道府県が選択されていません", message: "都道府県を選択してください")
    }else if(globalVar.spotDataList.count == 0){
      showAlert(title: "スポットが登録されていません", message: "スポットを登録してください")
    }else if(transportationString == "0,0,0,0,0,0,0"){
      showAlert(title: "交通手段が選択されていません", message: "交通手段を1つ以上選択してください")
    }else if(pickerTextField.text! == ""){
      showAlert(title: "金額が選択されていません", message: "金額を選択してください")
    }else if(globalVar.spotDataList.count >= 1 && titleTextField.text != "" && prefecturesTextField.text != "" && pickerTextField.text != ""){
      globalVar.planTitle = titleTextField.text!
      globalVar.planArea = prefecturesTextField.text!
      globalVar.planPrice = pickerTextField.text!
      globalVar.planText = textView.text!
      globalVar.selectCount = 0
      settingImage()
      self.performSegue(withIdentifier: "toStartView", sender: nil)
    }
  }
  
  func settingImage(){
    for i in 0 ... globalVar.spotDataList.count - 1{
      for f in 0 ..< 3 {
        var url = NSURL()
        switch f{
        case 0:
          url = NSURL(string: globalVar.spotDataList[i].image_A)!
          imageNumber += 1
          print("URL1",url)
          break
        case 1:
          url = NSURL(string: globalVar.spotDataList[i].image_B)!
          imageNumber += 1
          print("URL2",url)
          break
        case 2:
          url = NSURL(string: globalVar.spotDataList[i].image_C)!
          imageNumber += 1
          print("URL3",url)
          break
        default:
          break
        }
        if url != NSURL(string: "") {
          imageCount += 1
          let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url as URL], options: nil)
          let asset: PHAsset = fetchResult.firstObject!
          let manager = PHImageManager.default()
          manager.requestImage(for: asset, targetSize: CGSize(width: 140, height: 140), contentMode: .aspectFill, options: nil) { (image, info) in
            // imageをセットする
            switch f{
            case 0:
              self.pickedImageA = image
              self.postImage(pickedImage: self.pickedImageA!,flag:f,number: i)
              break
            case 1:
              self.pickedImageB = image
              self.postImage(pickedImage: self.pickedImageB!,flag:f,number: i)
              break
            case 2:
              self.pickedImageC = image
              if(i == self.globalVar.spotDataList.count - 1){
              }
              self.postImage(pickedImage: self.pickedImageC!,flag:f,number: i)
              break
            default:
              break
            }
          }
        }else{
          switch f{
          case 0:
            self.globalVar.spotImageA[i] = ""
            print(i,":",f,":",globalVar.spotImageA)
            break
          case 1:
            self.globalVar.spotImageB[i] = ""
            print(i,":",f,":",globalVar.spotImageB)
            break
          case 2:
            self.globalVar.spotImageC[i] = ""
            print(i,":",f,":",globalVar.spotImageC)
            if(i == globalVar.spotDataList.count - 1 && imageCount == 0){
              print("EndBBB")
              postPlan()
            }
            break
          default:
            break
          }
        }
      }
    }
  }
  
  func postImage(pickedImage:UIImage,flag:Int,number:Int){
    print("number:",number)
    // UIImageからPNGに変換してアップロード
    if(imageFlagList[imageNumber - 1] == 0){
      self.imageFlagList[imageNumber - 1] = 1
      let imageData = pickedImage.jpegData(compressionQuality: 1.0)
      print("FlagA",number,":",flag,":",imageFlagList[number])
      let body = httpBody(imageData!, fileName: "\(number)-\(flag).jpg")
      let url = URL(string: "http://35.200.26.70:443/api/v1/image/upload")!
      fileUpload(url, data: body) {(data, response, error) in
        if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
          print("FlagB",number,":",flag,":",self.imageFlagList[number])
          if response.statusCode == 200 {
            print("FlagC",number,":",flag,":",self.imageFlagList[number])
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
            switch flag{
            case 0:
              self.globalVar.spotImageA[number] = "http://35.200.26.70:8080/test1/\(imageStr)"
              self.setImageCount += 1
              print(self.imageFlagList[number])
              print(number,":",flag,":",self.globalVar.spotImageA)
              break
            case 1:
              self.globalVar.spotImageB[number] = "http://35.200.26.70:8080/test1/\(imageStr)"
              self.setImageCount += 1
              print(number,":",flag,":",self.globalVar.spotImageB)
              break
            case 2:
              self.globalVar.spotImageC[number] = "http://35.200.26.70:8080/test1/\(imageStr)"
              self.setImageCount += 1
              print(number,":",flag,":",self.globalVar.spotImageC)
              break
            default:
              break
            }
            print("Upload done",data as Any)
            print(String(data: data!, encoding: .utf8) ?? "")
            if(self.setImageCount == self.imageCount){
              print("EndAAA")
              self.setImageCount += 100
              self.postPlan()
            }
          } else {
            print(response.statusCode)
          }
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
    print("FlagE",imageFlagList[0])
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
  func postPlan(){
    let transportationString = transportation.reduce("") { $0 + String($1) }
    let str : String = "token=\(globalVar.token)&plan_title=\(globalVar.planTitle)&plan_comment=\(globalVar.planText)&transportation=\(transportationString)&price=\(globalVar.planPrice)&area=\(globalVar.planArea)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/plan/register")
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
        self.globalVar.planArea = ""
        self.globalVar.planPrice = ""
        self.globalVar.planText = ""
        self.globalVar.planTitle = ""
        self.getPlan()
    //        self.globalVar.selectSpot = ["スポットを追加"]
    //        self.globalVar.spotDataList = []
    //        self.imageCount = 0
    //        self.setImageCount = 0
    //        for i in 0 ... 19{
    //          self.globalVar.spotImageA[i] = ""
    //          self.globalVar.spotImageB[i] = ""
    //          self.globalVar.spotImageC[i] = ""
    //        }
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
        let planId : Int
        let userId : String
        let planTitle : String
        let planArea : String
        let planComment : String?
        let planPrice : String
        let transportation : String
//        let planDate : String
        let date : Date? = NSDate() as Date
        enum CodingKeys: String, CodingKey {
          case planId = "plan_id"
          case userId = "user_id"
          case planTitle = "plan_title"
          case planArea = "area"
          case planComment = "plan_comment"
          case planPrice = "price"
          case transportation = "transportation"
//          case planDate = "pla_date"
          case date
        }
      }
    }
  
  func getPlan(){
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/plan/find?user_id=\(globalVar.userId)")
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let allData = try! JSONDecoder().decode(AllData.self, from: data)
        if(allData.message == ""){
          let setNumber = allData.record!.count - 1
          self.setPlanId = allData.record![setNumber].planId
          self.postSpot()
        }else{
          self.showAlert(title: allData.message!, message: "再ログインしてください")
        }
      }
    }.resume()
  }

  func postSpot(){
    for i in 0...globalVar.spotDataList.count - 1{
      let dateFormater = DateFormatter()
      dateFormater.locale = Locale(identifier: "ja_JP")
      dateFormater.dateFormat = "yyyy-MM-dd"
      let date = dateFormater.string(from: globalVar.spotDataList[i].datetime)
      print(date)
      self.postSpotCount += 1
      let str = "token=\(globalVar.token)&spot_title=\(globalVar.spotDataList[i].spot_name)&spot_address=\(globalVar.spotDataList[i].latitude),\(globalVar.spotDataList[i].longitude)&spot_comment=\(globalVar.spotDataList[i].comment)&spot_image_a=\(globalVar.spotImageA[i])&spot_image_b=\(globalVar.spotImageB[i])&spot_image_c=\(globalVar.spotImageC[i])&plan_id=\(setPlanId)&user_id=\(globalVar.userId)&spot_date=\(date)"
      let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/spot/register")
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
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func textViewSetteings() {
    // 枠のカラー
    textView.layer.borderColor = UIColor.gray.cgColor
    // 枠の幅
    textView.layer.borderWidth = 1.0
    // 枠を角丸にする場合
    textView.layer.cornerRadius = 10.0
    textView.layer.masksToBounds = true
  }
  @objc func commitButtonTapped (){
    self.view.endEditing(true)
    self.resignFirstResponder()
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
    textView.inputAccessoryView = kbToolBar
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
      performSegue(withIdentifier: "toDetailUserView", sender: nil)
    default : return
    }
  }
  
  enum actionTag: Int {
    case action1 = 1
    case action2 = 2
    case action3 = 3
    case action4 = 4
    case action5 = 5
    case action6 = 6
    case action7 = 7
  }
  
  func idSetRealm(){
    let realm = try! Realm()
    
    let user = realm.objects(UserModel.self)
    for _user in user {
      globalVar.userId = _user.user_id
    }
  }
  @IBAction func pushButton(_ sender: Any) {
    if let button = sender as? UIButton {
      if let tag = actionTag(rawValue: button.tag) {
        switch tag {
        case .action1:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_walk_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[0] = "1,"
          }else{
            button.setImage(UIImage(named: "s_walk.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[0] = "0,"
          }
        case .action2:
          if(imageFlag2 == 0){
            button.setImage(UIImage(named: "s_bicycle_on.png"), for:UIControl.State())
            imageFlag2 = 1
            transportation[1] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bicycle.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[1] = "0,"
          }
        case .action3:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_car_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[2] = "1,"
          }else{
            button.setImage(UIImage(named: "s_car.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[2] = "0,"
          }
        case .action4:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_bus_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[3] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bus.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[3] = "0,"
          }
        case .action5:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_train_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[4] = "1,"
          }else{
            button.setImage(UIImage(named: "s_train.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[4] = "0,"
          }
        case .action6:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_airplane_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[5] = "1,"
          }else{
            button.setImage(UIImage(named: "s_airplane.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[5] = "0,"
          }
        case .action7:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_boat_on.png"), for:UIControl.State())
            imageFlag1 = 1
            transportation[6] = "1"
          }else{
            button.setImage(UIImage(named: "s_boat.png"), for:UIControl.State())
            imageFlag1 = 0
            transportation[6] = "0"
          }
        }
      }
    }
  }
}

