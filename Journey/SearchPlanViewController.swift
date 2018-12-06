//
//  SearchPlanViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/27.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class SearchPlanViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIPickerViewDelegate,UIPickerViewDataSource{
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  @IBOutlet weak var SearchBarTextField: UITextField!
  @IBOutlet weak var goodTextField: UITextField!
  @IBOutlet weak var moneyTextField: UITextField!
  @IBOutlet weak var regionTextField: UITextField!
  @IBOutlet weak var generationTextField: UITextField!
  var tableView: UITableView!
  let statusBarHeight = UIApplication.shared.statusBarFrame.height
  var navigationBarHeight: CGFloat = 0
  var textFieldHeight: CGFloat = 0
  var textFieldY: CGFloat = 0
  
  private var tabBar:TabBar!
  
  var goodList = ["-非選択-","10以下", "11 ~ 50", "51 ~ 100", "101 ~ 500", "500以上"]
  var moneyList = ["-非選択-","500円以下", "501円 ~ 1000円", "1001円 ~ 5000円", "5001円 ~ 10000円", "10001円以上"]
  var regionList = ["-非選択-","北海道", "東北", "関東", "中部", "近畿", "中国", "四国", "九州"]
  var generationList = ["-非選択-","10歳未満","10代","20代","30代","40代","50代","60代","70代","80代","90代","100歳以上"]
  
  var transportation = ["0,","0,","0,","0,","0,","0,","0"]
  var imageFlag1 = 0
  var imageFlag2 = 0
  var imageFlag3 = 0
  var imageFlag4 = 0
  var imageFlag5 = 0
  var imageFlag6 = 0
  var imageFlag7 = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
    textFieldHeight = SearchBarTextField.layer.bounds.height
    textFieldY = SearchBarTextField.frame.origin.y
    SearchBarTextField.placeholder = "検索枠"
    SearchBarTextField.backgroundColor = UIColor.white
    //SearchBarTextField.returnKeyType = .search
    
    let goodPickerView = UIPickerView()
    goodPickerView.tag = 1
    goodPickerView.delegate = self
    goodTextField.inputView = goodPickerView
    
    let moneyPickerView = UIPickerView()
    moneyPickerView.tag = 2
    moneyPickerView.delegate = self
    moneyTextField.inputView = moneyPickerView
    
    let regionPickerView = UIPickerView()
    regionPickerView.tag = 3
    regionPickerView.delegate = self
    regionTextField.inputView = regionPickerView
    
    let generationPickerView = UIPickerView()
    generationPickerView.tag = 4
    generationPickerView.delegate = self
    generationTextField.inputView = generationPickerView
    
    goodTextField.placeholder = "いいね数を選択してください"
    moneyTextField.placeholder = "金額を選択してください"
    regionTextField.placeholder = "地方を選択してください"
    generationTextField.placeholder = "年代を選択してください"
    
    SearchBarTextField.delegate = self
    
    //textViewSetteings()
    keyboardSettings()
    createTabBar()
  }
  
  @objc func commitButtonTapped (){
    self.view.endEditing(true)
    self.resignFirstResponder()
    SearchBarTextField.resignFirstResponder()
    tableView.removeFromSuperview()
    addHistory(text: SearchBarTextField.text!)
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
    SearchBarTextField.inputAccessoryView = kbToolBar
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 1{
      return goodList.count
    }else if pickerView.tag == 2{
      return moneyList.count
    }else if pickerView.tag == 3{
      return regionList.count
    }else{
      return generationList.count
    }
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 1{
      return goodList[row]
    }else if pickerView.tag == 2{
      return moneyList[row]
    }else if pickerView.tag == 3{
      return regionList[row]
    }else{
      return generationList[row]
    }
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 1{
      goodTextField.text = goodList[row]
    }else if pickerView.tag == 2{
      moneyTextField.text = moneyList[row]
    }else if pickerView.tag == 3{
      regionTextField.text = regionList[row]
    }else{
      generationTextField.text = generationList[row]
    }
  }

  // 新しく履歴に追加
  func addHistory(text: String) {
    
    if text == "" {
      return
    }
    
    var histories = getInputHistory()
    
    /*for word in histories {
      if word == text {
        // すでに履歴にある場合は追加しない
        return
      }
    }*/
    
    histories.insert(text, at: 0)
    //userDefaults.set(histories, forKey: "inputHistory")
    let realm = try! Realm()
    
    let historyModel = HistoryModel()
    historyModel.history_word = text
    historyModel.datetime = Date()
    
    try! realm.write() {
      realm.add(historyModel, update: true)
    }
  }
  
  // 履歴を一つ削除
  func removeHistory(word: String) {

    let realm = try! Realm()
    
    let results = realm.objects(HistoryModel.self).filter("name == " + word).first
    try! realm.write {
      realm.delete(results!)
    }
  }
  
  // 履歴取得
  func getInputHistory() -> [String] {
    
    let realm = try! Realm()
    let historyModelList = realm.objects(HistoryModel.self)
    var historyList : [String] = []
    for _hm in historyModelList {
      historyList.append(_hm.history_word)
    }
    historyList.reverse()
    return historyList
  }
  
  // UITableViewCellから履歴を入力
  @objc func inputFromHistory(sender: UITapGestureRecognizer) {
    if let cell = sender.view as? UITableViewCell {
      SearchBarTextField.text = cell.textLabel?.text
    }
  }
  
  // MARK: - UITextFieldDelegate関連
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    tableView.removeFromSuperview()
    
    addHistory(text: textField.text!)
    
    textField.text = ""
    
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
    let topMargin = statusBarHeight + navigationBarHeight + textFieldY + textFieldHeight
    
    tableView = UITableView(frame: CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin))
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = UIColor(white: 0, alpha: 0.5)
    tableView.allowsSelection = false
    tableView.isScrollEnabled = false
    self.view.addSubview(tableView)
    
    return true
  }
  
  // MARK: - UITableView関連
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // テーブルセルの数を設定（必須）
    return getInputHistory().count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // テーブルセルを作成（必須）
    
    let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
    cell.textLabel?.text = getInputHistory()[indexPath.row]
    cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.inputFromHistory(sender:))))
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // テーブルセルの高さを設定
    return textFieldHeight
  }
  
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    // 左スワイプして出てくる削除ボタンのテキスト
    return "削除"
  }
  
  private func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    // 左スワイプして出てくる削除ボタンを押した時の処理
    
    removeHistory(word: getInputHistory()[indexPath.row])
    
    tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // すべてのセルを削除可能に
    return true
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
  
  enum actionTag: Int {
    case action1 = 1
    case action2 = 2
    case action3 = 3
    case action4 = 4
    case action5 = 5
    case action6 = 6
    case action7 = 7
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
