//
//  ButtonSettings.swift
//  Journey
//
//  Created by 石倉一平 on 2018/10/18.
//  Copyright © 2018 Swift-Biginners. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonSettings: UIButton {
  @IBInspectable var textColor: UIColor?
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.clear {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }
}
