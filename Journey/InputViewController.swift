//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps

class InputViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDataSource, UIPickerViewDelegate{

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var spotTable: UITableView!
  @IBOutlet weak var tableHeight: NSLayoutConstraint!
  @IBOutlet weak var pickerTextField: UITextField!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var subViewHeight: NSLayoutConstraint!
  
  var height = 46
  var count = 0
  var viewHeight = 0
  var text:Array = ["スポットを追加"]
  var pickOption = ["one", "two", "three", "seven", "fifteen"]
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickOption.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickOption[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    pickerTextField.text = pickOption[row]
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
    
    let camera = GMSCameraPosition.camera(withLatitude: -33.868,longitude:151.2086, zoom:15)
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:60,width:myFrameSize.width,height:300),camera:camera)
    let marker = GMSMarker()
    
    marker.icon = UIImage(named:"thumbs-up")
    marker.map = mapView
    self.subView.addSubview(mapView)
    
    titleTextField.placeholder = "プラン名を入力"
    pickerTextField.placeholder = "選択してください"
    textView.text = "プラン説明"
    
    spotTable.delegate = self
    spotTable.dataSource = self
    tableHeight.constant = CGFloat(height)
    
    let pickerView = UIPickerView()
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
    let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(InputViewController.commitButtonTapped))
    kbToolBar.items = [spacer, commitButton]
    textView.inputAccessoryView = kbToolBar
  }


}

