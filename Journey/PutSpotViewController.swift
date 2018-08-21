//
//  PutSpotViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/09.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import CoreMotion
import Darwin
import RealmSwift

class PutSpotViewController: UIViewController, UITabBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate,  UITextFieldDelegate{
    
      private var tabBar:TabBar!

    /*override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        createTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    

    /****************/
    
    var lat:Double = 0
    var lng:Double = 0
    
    var aaa = -33.868
    var bbb = 151.2086
    
    let top = "エラー"
    let message = "名前が入力されていません"
    let okText = "OK"
    
    var latitudeList: [Double] = []
    var longitudeList: [Double] = []
    var nameList: [String] = []
    
    var spotDataList : [ListSpotModel] = []
    
    var locationManager: CLLocationManager!
    let motionManager = CMMotionManager()
    
    //@IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var selectSpotButton: UIButton!
    
    let myFrameSize:CGSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: aaa,longitude:bbb, zoom:15)
        let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:UIApplication.shared.statusBarFrame.size.height +  (self.navigationController?.navigationBar.frame.size.height)!,width:myFrameSize.width,height:myFrameSize.height/3),camera:camera)
        let marker = GMSMarker()
        
        marker.icon = UIImage(named:"thumbs-up")
        marker.map = mapView
        
        self.view.addSubview(mapView)
        
        if CLLocationManager.locationServicesEnabled() {
            print("位置情報通過")
            locationManager = CLLocationManager()
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.startUpdatingLocation()
        }
        
        createTabBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("位置情報通過４")
        switch status {
        case .notDetermined:
            print("位置情報通過６")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlert()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            print("位置情報通過５")
            break
        }
    }
    @IBAction func tappedMapButton(_ sender: Any) {
        if nameTextField.text == "" {
            let alert = UIAlertController(title: top, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okayButton)
            present(alert, animated: true, completion: nil)
            return
        }else{
            let realm = try! Realm()
            
            let date:Date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyyMMddHHmmssSSS"
            
            let spotModel = SpotModel()
            spotModel.spot_id = Int(format.string(from: date))!
            spotModel.spot_name = nameTextField.text!
            spotModel.latitude = lat
            spotModel.longitude = lng
            
            try! realm.write() {
                realm.add(spotModel)
            }
            
            print(realm.objects(SpotModel.self))
        }
        /*if CLLocationManager.locationServicesEnabled() {
            print("位置情報通過")
            locationManager = CLLocationManager()
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.startUpdatingLocation()
        }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置情報通過２")
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                print("Error")
                return
        }
        
        let latitude:Double = atof("".appendingFormat("%.6f", newLocation.coordinate.latitude))
        let longitude:Double = atof("".appendingFormat("%.6f", newLocation.coordinate.longitude))
        
        latitudeList.append(newLocation.coordinate.latitude)
        longitudeList.append(newLocation.coordinate.longitude)
        nameList.append(nameTextField.text!)
        
        var spotData : ListSpotModel =
            ListSpotModel(la: newLocation.coordinate.latitude,lo: newLocation.coordinate.longitude,na: nameTextField.text!)
        
        spotDataList.append(spotData)
        
        lat = newLocation.coordinate.latitude
        lng = newLocation.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude,longitude:longitude, zoom:15)
        let mapView = GMSMapView.map(withFrame: CGRect(x:0,y:UIApplication.shared.statusBarFrame.size.height +  (self.navigationController?.navigationBar.frame.size.height)!,width:myFrameSize.width,height:myFrameSize.height/3),camera:camera)
        self.view.addSubview(mapView)
        
        let marker: GMSMarker = GMSMarker()
        
        marker.position = camera.target
        
        marker.snippet = "NOW"
        
        marker.map = mapView
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
    }
    func showAlert() {
        print("位置情報通過３")
        let alert = UIAlertController(title: "GPSがオフになっています", message: "設定を押して位置情報を許可してください", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "設定", style: UIAlertActionStyle.default){(action: UIAlertAction) in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url as URL)
        }
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func tappedSelectSpotButton(_ sender: Any) {
        goToSelectSpot()
    }
    
    func goToSelectSpot(){
        self.performSegue(withIdentifier: "goSelectSpot", sender:spotDataList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! SelectSpotViewController
        nextViewController.spotDataList = sender as! [ListSpotModel]
    }
    
    /****************/
    
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
        tabBar.barTintColor = UIColor.lightGray
        //選択されていないボタンの色
        tabBar.unselectedItemTintColor = UIColor.black
        //ボタンを押した時の色
        tabBar.tintColor = UIColor.black
        //ボタンを生成
        let home:UITabBarItem = UITabBarItem(title: "home", image: UIImage(named:"home.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 1)
        let search:UITabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        let favorites:UITabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
        let setting:UITabBarItem = UITabBarItem(title: "setting", image: UIImage(named:"settings.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 4)
        //ボタンをタブバーに配置する
        tabBar.items = [home,search,favorites,setting]
        //デリゲートを設定する
        tabBar.delegate = self
        
        self.view.addSubview(tabBar)
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 1:
            print("１")
        case 2:
            print("２")
        case 3:
            print("３")
        case 4:
            print("４")
        default : return
            
        }
    }

}
