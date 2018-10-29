//
//  CreateUserViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/22.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController , UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate{

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var userIdTextField: UITextField!
  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var passTextField: UITextField!
  @IBOutlet weak var nextPassTextField: UITextField!
  @IBOutlet weak var generationTextField: UITextField!
  @IBOutlet weak var genderTextField: UITextField!
  @IBOutlet weak var iconImageView: UIImageView!
  
  var keyboardFlag = 0
  var globalVar = GlobalVar.shared
  let gender = ["-性別を選択-","男性","女性"]
  let generation = ["-年代を選択-","10歳未満","10代","20代","30代","40代","50代","60代","70代","80代","90代","100歳以上"]
  var str : String = ""
  var userId:Array<String> = []
  var pass : String = ""
  var nextPass : String = ""
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 1{
      return generation.count
    }else{
      return gender.count
    }
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 1{
      return generation[row]
    }else{
      return gender[row]
    }
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 1{
      generationTextField.text = generation[row]
    }else{
      genderTextField.text = gender[row]
    }
  }
  override func viewDidLoad() {
        super.viewDidLoad()
    self.userIdTextField.delegate = self
    self.userNameTextField.delegate = self
    
    if myFrameSize.height >= 812{
      //scrollViewsetScrollEnabled
      scrollView.isScrollEnabled = false
    }
    
    if(globalVar.userId != ""){
      userIdTextField.text = globalVar.userId
    }else{
      userIdTextField.placeholder = "半角英数字で20文字以下"
    }
    if(globalVar.userName != ""){
      userNameTextField.text = globalVar.userName
    }else{
      userNameTextField.placeholder = "20文字以下"
    }
    if(globalVar.userPass != ""){
      passTextField.text = globalVar.userPass
    }else{
      passTextField.placeholder = "半角英数字8文字以上20文字以下"
    }
    nextPassTextField.placeholder = "同じパスワード入力"
    passTextField.isSecureTextEntry = true
    nextPassTextField.isSecureTextEntry  = true
    if(globalVar.userGeneration != ""){
      generationTextField.text = globalVar.userGeneration
    }else{
      generationTextField.placeholder = "年代を選択"
    }
    if(globalVar.userGender != ""){
      genderTextField.text = globalVar.userGender
    }else{
      genderTextField.placeholder = "性別を選択"
    }
    
    let genderPickerView = UIPickerView()
    genderPickerView.tag = 2
    genderPickerView.delegate = self
    genderTextField.inputView = genderPickerView
    
    let generationPickerView = UIPickerView()
    generationPickerView.tag = 1
    generationPickerView.delegate = self
    generationTextField.inputView = generationPickerView
    

        // Do any additional setup after loading the view.
    }
  @IBAction func tappedBackButton(_ sender: Any) {
    performSegue(withIdentifier: "backIndexView", sender: nil)
  }
  // キーボードが現れた時に、画面全体をずらす。
  @objc func keyboardWillShow(notification: Notification?) {
    if(keyboardFlag == 0){
      let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      UIView.animate(withDuration: duration!, animations: { () in
        let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
        self.view.transform = transform
        
      })
    }
  }
  
//  private func textFieldDidBeginEditing(textField: UITextField) {
//    if(textField.tag == 0 || textField.tag == 1){
//      keyboardFlag = 1
//    }else{
//      keyboardFlag = 0
//    }
//  }
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
  
  // キーボードが消えたときに、画面を戻す
  @objc func keyboardWillHide(notification: Notification?) {
    if(keyboardFlag == 0){
      let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
      UIView.animate(withDuration: duration!, animations: { () in
        
        self.view.transform = CGAffineTransform.identity
      })
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
    return true
  }

  @IBAction func tappedConfirmationButton(_ sender: Any) {
//    let pattern = "^[A-Za-z0-9]{1,}$"
//    let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
    if(userIdTextField.text == ""){
      showAlert(title: "ユーザーIDが入力されていません", message: "ユーザーIDを入力してください")
    }else if((userIdTextField.text?.count)! > 20){
      showAlert(title: "ユーザーIDが20文字を超えています", message: "文字数を20文字以内にしてください")
    }else if(userNameTextField.text == ""){
      showAlert(title: "名前が入力されていません", message: "名前を入力してください")
    }else if((userNameTextField.text?.count)! > 20){
      showAlert(title: "ユーザー名が20文字を超えています", message: "文字数を20文字以内にしてください")
    }else if(passTextField.text == ""){
      showAlert(title: "パスワードが入力されていません", message: "8文字以上,20文字以下で入力してください")
    }else if((passTextField.text?.count)! < 8){
      showAlert(title: "パスワードの文字数が足りません", message: "8文字以上,20文字以下で入力してください")
    }else if(passTextField.text!.count > 20){
      showAlert(title: "パスワードの文字数が多すぎます", message: "8文字以上,20文字以下で入力してください")
    }
//    else if (predicate.evaluate(with: passTextField.text)){
//      showAlert(title: "パスワードに半角英数字以外の文字が含まれています", message: "半角英数字で入力してください")
//    }else if(predicate.evaluate(with: userIdTextField.text)){
//      showAlert(title: "ユーザーIDに半角英数字以外の文字が含まれています", message: "半角英数字で入力してください")
//    }
    else if(nextPassTextField.text == ""){
      showAlert(title: "確認用パスワードが入力されていません", message: "8文字以上,20文字以下で入力してください")
    }else if((nextPassTextField.text?.count)! < 8){
      showAlert(title: "確認用パスワードの文字数が足りません", message: "8文字以上,20文字以下で入力してください")
    }else if(nextPassTextField.text!.count > 20){
      showAlert(title: "確認用パスワードの文字数が多すぎます", message: "8文字以上,20文字以下で入力してください")
    }else if(passTextField.text != nextPassTextField.text){
      showAlert(title: "パスワードの文字が確認用と一致しません", message: "パスワードを再度入力してください")
    }else if(generationTextField.text == ""){
      showAlert(title: "年代が選択されていません", message: "年代を選択してください")
    }else if(genderTextField.text == ""){
      showAlert(title: "性別が選択されていません", message: "性別を選択してください")
    }else{
      globalVar.userId = userIdTextField.text!
      globalVar.userName = userNameTextField.text!
      globalVar.userPass = passTextField.text!
      globalVar.userGender = genderTextField.text!
      globalVar.userGeneration = generationTextField.text!
      globalVar.userIcon = iconImageView.image!
      performSegue(withIdentifier: "toConfirmationView", sender: nil)
    }
  }
  func showAlert(title:String,message:String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let cancelButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
    alert.addAction(cancelButton)
    self.present(alert, animated: true, completion: nil)
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
