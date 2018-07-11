//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var spotTable: UITableView!
  @IBOutlet weak var tableHeight: NSLayoutConstraint!
  
  var height = 46
  var count = 0
  var text:Array = ["スポットを追加"]
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return(text.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    cell.textLabel?.text = text[indexPath.row]
    
    return(cell)
  }
  
  func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
    let selectedNumber = text[indexPath.row]
    print(selectedNumber)
    if(selectedNumber == "スポットを追加" && text.count != 21){
      print("AAAA")
      count += 1
      let str = count.description
      text.append(str)
      height += 46
      tableHeight.constant = CGFloat(height)
      spotTable.reloadData()
    } else {
      text[0] = "これ以上追加できません"
      spotTable.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let camera = GMSCameraPosition.camera(withLatitude: -33.868,longitude:151.2086, zoom:15)
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:60,width:myFrameSize.width,height:300),camera:camera)
    let marker = GMSMarker()
    
    marker.icon = UIImage(named:"thumbs-up")
    marker.map = mapView
    self.subView.addSubview(mapView)
    
    titleTextField.placeholder = "プラン名を入力"
    
    spotTable.delegate = self
    spotTable.dataSource = self
    tableHeight.constant = CGFloat(height)
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

