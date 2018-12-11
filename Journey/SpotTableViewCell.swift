//
//  SpotTableViewCell.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/12/10.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class SpotTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var spotNameLabel: UILabel!
  @IBOutlet weak var spotCommentLabel: UILabel!
  @IBOutlet weak var spotImageView: UIImageView!
  
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
    return UITableViewCell()
  }

}
