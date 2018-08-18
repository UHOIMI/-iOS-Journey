//
//  TabBar.swift
//  Journey
//
//  Created by 石倉一平 on 2018/08/18.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class TabBar: UITabBar {

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var size = super.sizeThatFits(size)
    size.height = 58
    return size
  }
  
}
