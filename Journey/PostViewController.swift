//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps

class PostViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate{

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
  var viewHeight = 0
  var text:Array = ["スポットを追加"]
  var pickOption = ["one", "two", "three", "seven", "fifteen"]
  var prefectures = [ "北海道", "青森県", "岩手県", "宮城県", "秋田県","山形県", "福島県", "茨城県", "栃木県", "群馬県","埼玉県", "千葉県", "東京都", "神奈川県", "新潟県","富山県", "石川県", "福井県", "山梨県", "長野県","岐阜県", "静岡県", "愛知県", "三重県", "滋賀県","京都府", "大阪府", "兵庫県", "奈良県", "和歌山県","鳥取県", "島根県", "岡山県", "広島県", "山口県","徳島県", "香川県", "愛媛県", "高知県", "福岡県","佐賀県", "長崎県", "熊本県", "大分県", "宮崎県","鹿児島県", "沖縄県"]
 
  var imageFlag1 = 0
  var imageFlag2 = 0
  var imageFlag3 = 0
  var imageFlag4 = 0
  var imageFlag5 = 0
  var imageFlag6 = 0
  var imageFlag7 = 0
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
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
    return(text.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    cell.textLabel?.text = text[indexPath.row]
    
    return(cell)
  }
  
  func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
    let selectedNumber = text[indexPath.row]
    print(selectedNumber)
    if(selectedNumber == "スポットを追加" && text.count != 21){
      count += 1
      let str = count.description
      text.append(str)
      viewHeight = Int(subView.frame.height) + 46
      subViewHeight.constant = CGFloat(viewHeight)
      print("Height:",viewHeight)
      height += 46
      tableHeight.constant = CGFloat(height)
      spotTable.reloadData()
    } else if(text.count == 21) {
      text[0] = "これ以上追加できません"
      spotTable.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
      self.text.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.height -= 46
      self.spotTable.reloadData()
    }
    deleteButton.backgroundColor = UIColor.red
    return [deleteButton]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let camera = GMSCameraPosition.camera(withLatitude: 35.710063,longitude:139.8107, zoom:15)
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:0,width:myFrameSize.width,height:300),camera:camera)
    let marker = GMSMarker()
    
    marker.icon = UIImage(named:"thumbs-up")
    marker.map = mapView
    self.subView.addSubview(mapView)
    
    titleTextField.placeholder = "プラン名を入力"
    prefecturesTextField.placeholder = "都道府県を選択してください"
    pickerTextField.placeholder = "金額を選択してください"
    textView.text = "プラン説明"
    
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
    
    textViewSetteings()
    keboardSettings()
  
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
  func keboardSettings(){
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
          }else{
            button.setImage(UIImage(named: "s_walk.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action2:
          if(imageFlag2 == 0){
            button.setImage(UIImage(named: "s_bicycle_on.png"), for:UIControlState())
            imageFlag2 = 1
          }else{
            button.setImage(UIImage(named: "s_bicycle.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action3:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_car_on.png"), for:UIControlState())
            imageFlag1 = 1
          }else{
            button.setImage(UIImage(named: "s_car.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action4:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_bus_on.png"), for:UIControlState())
            imageFlag1 = 1
          }else{
            button.setImage(UIImage(named: "s_bus.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action5:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_train_on.png"), for:UIControlState())
            imageFlag1 = 1
          }else{
            button.setImage(UIImage(named: "s_train.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action6:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_airplane_on.png"), for:UIControlState())
            imageFlag1 = 1
          }else{
            button.setImage(UIImage(named: "s_airplane.png"), for:UIControlState())
            imageFlag1 = 0
          }
        case .action7:
          if(imageFlag1 == 0){
            button.setImage(UIImage(named: "s_boat_on.png"), for:UIControlState())
            imageFlag1 = 1
          }else{
            button.setImage(UIImage(named: "s_boat.png"), for:UIControlState())
            imageFlag1 = 0
          }
        }
      }
    }
  }
}

