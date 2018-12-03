//
//  PlanTableViewCell.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/22.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class PlanTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var planNameLabel: UILabel!
  @IBOutlet weak var planUserIconImageView: UIImageView!
  @IBOutlet weak var planUserNameLabel: UILabel!
  @IBOutlet weak var planImageView: UIImageView!
  @IBOutlet weak var planSpotNameLabel1: UILabel!
  @IBOutlet weak var planSpotNameLabel2: UILabel!
  @IBOutlet weak var planDateLabel: UILabel!
  @IBOutlet weak var planFavoriteLabel: UILabel!
  @IBOutlet weak var planSpotCountLabel: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print("いいいいい")
    return UITableViewCell()
  }

}
