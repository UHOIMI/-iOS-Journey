import Foundation
import UIKit

class Keyboard: UITextField,UITextFieldDelegate{
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit(){
    let tools = UIToolbar()
    tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
    let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(Keyboard.closeButtonTapped))
    tools.items = [spacer, closeButton]
    self.inputAccessoryView = tools
  }
  
  @objc func closeButtonTapped(){
    self.endEditing(true)
    self.resignFirstResponder()
  }
}

