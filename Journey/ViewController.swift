//
//  ViewController.swift
//  Journey
//
//  Created by 石倉一平 on 2018/07/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var subView: UIView!
  
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let camera = GMSCameraPosition.camera(withLatitude: -33.868,longitude:151.2086, zoom:15)
    let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:60,width:myFrameSize.width,height:myFrameSize.height/2.5),camera:camera)
    let marker = GMSMarker()
    
    marker.icon = UIImage(named:"thumbs-up")
    marker.map = mapView
    self.subView.addSubview(mapView)
    
    titleTextField.placeholder = "プラン名を入力"
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

