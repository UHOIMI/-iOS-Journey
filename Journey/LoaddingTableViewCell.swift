//
//  LoaddingTableViewCell.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/22.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class LoaddingTableViewCell: UITableViewCell {
  @IBOutlet weak var IndicatoreView: UIActivityIndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func startAnimationg(){
    IndicatoreView.startAnimating()
  }
}
