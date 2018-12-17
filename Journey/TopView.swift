//
//  TopView.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/12/16.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class TopView: UIView {
  
  @IBOutlet weak var planNameLabel: UILabel!
  @IBOutlet weak var planUserIconImageView: UIImageView!
  @IBOutlet weak var planUserNameLabel: UILabel!
  @IBOutlet weak var planImageView: UIImageView!
  @IBOutlet weak var planSpotNameLabel1: UILabel!
  @IBOutlet weak var planSpotNameLabel2: UILabel!
  @IBOutlet weak var planDateLabel: UILabel!
  @IBOutlet weak var planFavoriteLabel: UILabel!
  @IBOutlet weak var planSpotCountLabel: UILabel!

  override init(frame: CGRect) {
    super.init(frame: frame)
    loadNib()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    loadNib()
  }
  
  func loadNib() {
    if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
      view.frame = self.bounds
      self.addSubview(view)
    }
  }

}
