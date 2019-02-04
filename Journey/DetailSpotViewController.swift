//
//  DetailSpotViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/10.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import CoreMotion
import Photos

class DetailSpotViewController: UIViewController, UITabBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate{
    
    private var tabBar:TabBar!
    var globalVar = GlobalVar.shared
    
    var lat:Double = 0
    var lng:Double = 0
    
    var aaa = -33.868
    var bbb = 151.2086
    
    var locationManager: CLLocationManager!
    let motionManager = CMMotionManager()
  
    var postFlag : Bool = false
    var editFlag : Bool = false
    var getImages : [UIImage] = []
    var spotData : ListSpotModel = ListSpotModel()
    var tappedIndex = 0
    
    let myFrameSize:CGSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var userBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var spotCommentLabel: UILabel!
    
    @IBOutlet weak var spotImageView1: UIImageView!
    @IBOutlet weak var spotImageView2: UIImageView!
    @IBOutlet weak var spotImageView3: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = true
//      
//        let leftButton: UIButton = UIButton()
//        leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        leftButton.setImage(globalVar.userIcon, for: UIControl.State.normal)
//        leftButton.imageView?.layer.cornerRadius = 40 * 0.5
//        leftButton.imageView?.clipsToBounds = true
//        leftButton.addTarget(self, action: #selector(DetailSpotViewController.userIconTapped(sender:)), for: .touchUpInside)
//        userBarButtonItem.customView = leftButton
//        userBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
//        userBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
      
        let camera = GMSCameraPosition.camera(withLatitude: spotData.latitude,longitude:spotData.longitude, zoom:15)
        let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:UIApplication.shared.statusBarFrame.size.height +  (self.navigationController?.navigationBar.frame.size.height)!,width:myFrameSize.width,height:myFrameSize.height/3),camera:camera)
        let marker = GMSMarker()
        
        marker.icon = UIImage(named:"thumbs-up")
        marker.position = camera.target
        marker.map = mapView
        
        spotCommentLabel.numberOfLines = 0
        spotCommentLabel.sizeToFit()
        
        self.view.addSubview(mapView)
        
        if CLLocationManager.locationServicesEnabled() {
            print("位置情報通過")
            locationManager = CLLocationManager()
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.startUpdatingLocation()
        }
        
        spotNameLabel.text = spotData.spot_name
        spotCommentLabel.text = spotData.comment
      
      if editFlag {
        editButton.title = ""
        editButton.isEnabled = true
        for i in 0..<3 {
          switch i{
          case 0:
            self.spotImageView1.image = getImages[i]
            break
          case 1:
            self.spotImageView2.image = getImages[i]
            break
          case 2:
            self.spotImageView3.image = getImages[i]
            break
          default:
            break
          }
        }
      }else{
      
        for i in 0..<3 {
            
            var url = NSURL()
            
            switch i{
            case 0:
                url = NSURL(string: spotData.image_A)!
                break
            case 1:
                url = NSURL(string: spotData.image_B)!
                break
            case 2:
                url = NSURL(string: spotData.image_C)!
                break
            default:
                break
            }
            
            if url != NSURL(string: "") {
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url as URL], options: nil)
                let asset: PHAsset = fetchResult.firstObject!
                let manager = PHImageManager.default()
                manager.requestImage(for: asset, targetSize: CGSize(width: 140, height: 140), contentMode: .aspectFill, options: nil) { (image, info) in
                    // imageをセットする
                    switch i{
                    case 0:
                        self.spotImageView1.image = image
                        break
                    case 1:
                        self.spotImageView2.image = image
                        break
                    case 2:
                        self.spotImageView3.image = image
                        break
                    default:
                        break
                    }
                }
            }
        }
      }
        
        createTabBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func putEditButton(_ sender: Any) {
        self.performSegue(withIdentifier: "changePutSpotView", sender:spotData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if(segue.identifier == "changePutSpotView"){
        let nextViewController = segue.destination as! PutSpotViewController
        nextViewController.spotData = sender as! ListSpotModel
        if(postFlag){
          nextViewController.postFlag = true
          nextViewController.tappedIndex = tappedIndex
        }
      }
    }
    
    
    func createTabBar(){
        let width = self.view.frame.width
        let height = self.view.frame.height
        //デフォルトは49
        let tabBarHeight:CGFloat = 58
        /**   TabBarを設置   **/
        tabBar = TabBar()
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                tabBar.frame = CGRect(x:0,y:height - tabBarHeight - 34.1,width:width,height:tabBarHeight)
            default:
                tabBar.frame = CGRect(x:0,y:height - tabBarHeight,width:width,height:tabBarHeight)
            }
        }
        //バーの色
        tabBar.barTintColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        //選択されていないボタンの色
        tabBar.unselectedItemTintColor = UIColor.black
        //ボタンを押した時の色
        tabBar.tintColor = UIColor.black
        //ボタンを生成
        let home:UITabBarItem = UITabBarItem(title: "home", image: UIImage(named:"home.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 1)
        let search:UITabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        let favorites:UITabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
        let setting:UITabBarItem = UITabBarItem(title: "setting", image: UIImage(named:"settings.png")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), tag: 4)
        //ボタンをタブバーに配置する
        tabBar.items = [home,search,favorites,setting]
        //デリゲートを設定する
        tabBar.delegate = self
        
        self.view.addSubview(tabBar)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 1:
            performSegue(withIdentifier: "toStartView", sender: nil)
        case 2:
            performSegue(withIdentifier: "toSearchView", sender: nil)
        case 3:
            performSegue(withIdentifier: "toTimelineView", sender: nil)
        case 4:
            performSegue(withIdentifier: "toDetailUserView", sender: nil)
        default : return
            
        }
    }
  
  @objc func userIconTapped(sender : AnyObject) {
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
  }

}
