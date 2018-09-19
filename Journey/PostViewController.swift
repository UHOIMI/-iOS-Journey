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
  var count = 0
  var viewHeight = 1000
  var pickOption = ["500円以下", "501円〜1000円", "1001円〜5000円", "5001円〜10000円", "10001円以上"]
  let prefectures:Array = [ "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県", "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県", "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県", "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県","鳥取県", "島根県", "岡山県", "広島県", "山口県","徳島県", "香川県", "愛媛県", "高知県", "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県"]
 
  var transportation = ["0,","0,","0,","0,","0,","0,","0"]
  
  let ipAddress = "192.168.100.102"
  
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
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
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
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.height -= 43
      self.tableHeight.constant = CGFloat(self.height)
      self.spotTable.reloadData()
      self.viewHeight -= 43
      self.subViewHeight.constant = CGFloat(self.viewHeight)
      self.subView.frame = CGRect(x:0, y: 0, width:375, height:self.viewHeight)
      if(indexPath.row == 21){
        self.globalVar.selectSpot[0] = "スポットを登録"
      }
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
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    alert.addAction(cancelButton)
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func tappedPostButton(_ sender: Any) {
    let transportationString = transportation.reduce("") { $0 + String($1) }
    if(titleTextField.text! == ""){
      showAlert(title: "プラン名が入力されていません", message: "プラン名を入力してください")
    }else if(titleTextField.text?.count == 21){
      showAlert(title: "プラン名が20文字を超えています", message: "文字数を20文字以内にしてください")
    }else if(prefecturesTextField.text == ""){
      showAlert(title: "都道府県が選択されていません", message: "都道府県を選択してください")
    }else if(globalVar.spotDataList.count == 0){
      showAlert(title: "スポットが登録されていません", message: "スポットを登録してください")
    }else if(transportationString == "0,0,0,0,0,0,0"){
      showAlert(title: "交通手段が選択されていません", message: "交通手段を1つ以上選択してください")
    }else if(pickerTextField.text! == ""){
      showAlert(title: "金額が選択されていません", message: "金額を選択してください")
    }
    if(globalVar.spotDataList.count >= 1 && titleTextField.text != "" && prefecturesTextField.text != "" && pickerTextField.text != ""){
      globalVar.planTitle = titleTextField.text!
      globalVar.planArea = prefecturesTextField.text!
      globalVar.planPrice = pickerTextField.text!
      globalVar.planText = textView.text!
      postSpot()
      self.performSegue(withIdentifier: "toStartView", sender: nil)
    }
  }

  func postSpot(){
    for i in 0...globalVar.spotDataList.count - 1{
      self.postSpotCount += 1
      print(self.postSpotCount)
      let str = "user_id=1&spot_title=\(globalVar.spotDataList[i].spot_name)&spot_address=\(globalVar.spotDataList[i].latitude),\(globalVar.spotDataList[i].longitude)&spot_comment=\(globalVar.spotDataList[i].comment)&spot_image_a=\(globalVar.spotDataList[i].image_A)&spot_image_b=\(globalVar.spotDataList[i].image_B)&spot_image_c=\(globalVar.spotDataList[i].image_C)"
      let url = URL(string: "http://\(ipAddress):3000/api/v1/spot/register")
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
          if (i == self.globalVar.spotDataList.count - 1){
            self.getSpot()
          }
        }
      }.resume()
    }
  }
  
  struct AllData : Codable{
    let status : Int
    let record : [Record]
    let message : String
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let spotId : Int
      let userId : Int
      let spotTitle : String
      let spotAddress : SpotAddress
      let spotComment : String
      let spotImageA : String?
      let spotImageB : String?
      let spotImageC : String?
      let date : Date? = NSDate() as Date
      enum CodingKeys: String, CodingKey {
        case spotId = "spot_id"
        case userId = "user_id"
        case spotTitle = "spot_title"
        case spotAddress = "spot_address"
        case spotComment = "spot_comment"
        case spotImageA = "spot_image_a"
        case spotImageB = "spot_image_b"
        case spotImageC = "spot_image_c"
        case date
      }
      struct SpotAddress : Codable{
        let x : Double
        let y : Double
        enum CodingKeys: String, CodingKey {
          case x
          case y
        }
      }
    }
  }
  
  func getSpot(){
    let url = URL(string: "http://\(ipAddress):3000/api/v1/spot/find?user_id=1")
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
        let max : Int = allData.record.count - 1
        var backCount = 0
        print(self.postSpotCount)
        for index in 0 ... self.postSpotCount - 1{
          backCount = max - index
          self.spotList.append(allData.record[backCount].spotId)
          print(self.spotList)
          if(index == self.postSpotCount - 1){
            self.spotList.reverse()
            self.postPlan()
          }
        }
      }
    }.resume()
  }
  
  func postPlan(){
    let transportationString = transportation.reduce("") { $0 + String($1) }
    var str : String = "user_id=1&plan_title=\(globalVar.planTitle)&plan_comment=\(globalVar.planText)&transportation=\(transportationString)&price=\(globalVar.planPrice)&area=\(globalVar.planArea)"
    for i in 0 ... spotList.count {
      if (i != spotList.count){
        str = str + "&spot_id_\(spotFlagList[i])=\(spotList[i])"
      }
    }
    print(str)
    let url = URL(string: "http://\(ipAddress):3000/api/v1/plan/register")
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
        self.globalVar.selectSpot = ["スポットを追加"]
        self.globalVar.spotDataList = []
      }
    }.resume()
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
    let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
    // 閉じるボタン
    let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.commitButtonTapped))
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
    notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  // Notificationを削除
  func removeObserver() {
    
    let notification = NotificationCenter.default
    notification.removeObserver(self)
  }
  
  // キーボードが現れた時に、画面全体をずらす。
  @objc func keyboardWillShow(notification: Notification?) {
    tabBar.isHidden = true
    let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
    UIView.animate(withDuration: duration!, animations: { () in
      let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
      self.view.transform = transform
      
    })
  }
  
  // キーボードが消えたときに、画面を戻す
  @objc func keyboardWillHide(notification: Notification?) {
    tabBar.isHidden = false
    let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
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
    let home:UITabBarItem = UITabBarItem(title: "home", image: UIImage(named:"home.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 1)
    let search:UITabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
    let favorites:UITabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
    let setting:UITabBarItem = UITabBarItem(title: "setting", image: UIImage(named:"settings.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 4)
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
      print("４")
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
  @IBAction func pushButton(_ sender: Any) {
    if let button = sender as? UIButton {
      if let tag = actionTag(rawValue: button.tag) {
        switch tag {
        case .action1:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_walk_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[0] = "1,"
          }else{
            button.setImage(UIImage(named: "s_walk.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[0] = "0,"
          }
        case .action2:
          if(imageFlag2 == 0){
            button.setImage(UIImage(named: "s_bicycle_on.png"), for:UIControlState())
            imageFlag2 = 1
            transportation[1] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bicycle.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[1] = "0,"
          }
        case .action3:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_car_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[2] = "1,"
          }else{
            button.setImage(UIImage(named: "s_car.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[2] = "0,"
          }
        case .action4:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_bus_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[3] = "1,"
          }else{
            button.setImage(UIImage(named: "s_bus.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[3] = "0,"
          }
        case .action5:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_train_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[4] = "1,"
          }else{
            button.setImage(UIImage(named: "s_train.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[4] = "0,"
          }
        case .action6:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_airplane_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[5] = "1,"
          }else{
            button.setImage(UIImage(named: "s_airplane.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[5] = "0,"
          }
        case .action7:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_boat_on.png"), for:UIControlState())
            imageFlag1 = 1
            transportation[6] = "1"
          }else{
            button.setImage(UIImage(named: "s_boat.png"), for:UIControlState())
            imageFlag1 = 0
            transportation[6] = "0"
          }
        }
      }
    }
  }
}

