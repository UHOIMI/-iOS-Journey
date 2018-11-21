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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(TimelineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
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
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sampleCell", for: indexPath)
    cell.textLabel?.text = "\(sampledatas[indexPath.row])"
    return cell
  }
  @objc func refreshControlValueChanged(sender: UIRefreshControl) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      sender.endRefreshing()
    })
  }

}
