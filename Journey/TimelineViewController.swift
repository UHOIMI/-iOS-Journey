//
//  TimelineViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/21.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var sampledatas = [1,2,3,4,5,6,7,8,9,10]
  var isaddload:Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
    //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    tableView.register(cellType: LoaddingTableViewCell.self)
    let footerCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LoaddingTableViewCell")!
    (footerCell as! LoaddingTableViewCell).startAnimationg()
    let footerView: UIView = footerCell.contentView
    tableView.tableFooterView = footerView
    tableView.addSubview(refreshControl)
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sampledatas.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: PlanTableViewCell = tableView.dequeueReusableCell(withIdentifier: "planCell", for : indexPath) as! PlanTableViewCell
    //let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath)
    cell.planNameLabel.text = sampledatas[indexPath.row].description + "プラン名"
    cell.planSpotNameLabel1.text = "スポット名"
    cell.planSpotNameLabel2.text = "スポット名"
    cell.planFavoriteLabel.text = 99999.description
    cell.planImageView.image = UIImage(named: "no-image.png")
    cell.planUserIconImageView.image = UIImage(named: "no-image.png")
    cell.planUserIconImageView.layer.cornerRadius = 40 * 0.5
    print(cell.planUserIconImageView.frame.width)
    cell.planUserIconImageView.clipsToBounds = true
    //cell.textLabel?.text = "\(sampledatas[indexPath.row])"
    return cell
  }
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
      self.sampledatas.insert(self.sampledatas[0] - 1, at: 0)
      self.tableView.reloadData()
      sender.endRefreshing()
    })
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (self.tableView.contentOffset.y + self.tableView.frame.size.height > self.tableView.contentSize.height && self.tableView.isDragging && isaddload == true){
      self.isaddload = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        for _ in 0..<2{
          self.sampledatas.append(self.sampledatas.last! + 1)
        }
        if(self.sampledatas.count > 50){
          self.isaddload = false
          self.tableView.tableFooterView = UIView()
        }else{
          self.isaddload = true
        }
        self.tableView.reloadData()
      }
    }
  }

}

extension UITableView {
  func register<T: UITableViewCell>(cellType: T.Type) {
    let className = cellType.className
    let nib = UINib(nibName: className, bundle: nil)
    register(nib, forCellReuseIdentifier: className)
  }
  
  func register<T: UITableViewCell>(cellTypes: [T.Type]) {
    cellTypes.forEach { register(cellType: $0) }
  }
  
  func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
    return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
  }
}

extension NSObject{
  class var className: String {
    return String(describing: self)
  }
  
  var className: String {
    return type(of: self).className
  }
  
}
