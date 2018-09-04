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
import Photos

class PutSpotViewController: UIViewController, UITabBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
    var message = ""
    let okText = "OK"
    
    var latitudeList: [Double] = []
    var longitudeList: [Double] = []
    var nameList: [String] = []
    
    var spotDataList : [ListSpotModel] = []
    var spotData : ListSpotModel = ListSpotModel()
    
    var locationManager: CLLocationManager!
    let motionManager = CMMotionManager()
    
    var selectImg = UIImage(named:"画像を選択")!
    var selectImgNum = 1
    
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var spotImageView1: UIImageView!
    @IBOutlet weak var spotImageView2: UIImageView!
    @IBOutlet weak var spotImageView3: UIImageView!
    
    var image1Path = ""
    var image2Path = ""
    var image3Path = ""
    
    
    @IBOutlet weak var selectSpotButton: UIButton!
    
    let myFrameSize:CGSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if spotData.spot_id != 0 {
            nameTextField.text = spotData.spot_name
            commentTextField.text = spotData.comment
            
            for i in 0..<3 {
                
                var url = NSURL()
                
                switch i{
                case 0:
                    url = NSURL(string: spotData.image_A)!
                    image1Path = spotData.image_A
                    break
                case 1:
                    url = NSURL(string: spotData.image_B)!
                    image2Path = spotData.image_B
                    break
                case 2:
                    url = NSURL(string: spotData.image_C)!
                    image3Path = spotData.image_C
                    break
                default:
                    break
                }
                
                if url != NSURL(string: "") {
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(withALAssetURLs: [url as URL], options: nil)
                    //let asset: PHAsset = fetchResult.firstObject as! PHAsset
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
                }else{
                    switch i{
                    case 0:
                        spotImageView1.image = selectImg
                        break
                    case 1:
                        spotImageView2.image = selectImg
                        break
                    case 2:
                        spotImageView3.image = selectImg
                        break
                    default:
                        break
                    }
                }
                
            }
        }else{
            spotImageView1.image = selectImg
            spotImageView2.image = selectImg
            spotImageView3.image = selectImg
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: spotData.latitude,longitude:spotData.longitude, zoom:15)
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
        
        message = ""
        if nameTextField.text == "" {
            message = "名前が入力されていません。\n"
        }
        if (nameTextField.text?.count)! > 20{
            message = "スポット名が文字数制限(20字)を超えています。\n"
        }
        if (commentTextField.text?.count)! > 140{
            message += "コメントが文字数制限(140字)を超えています。"
        }
        
        
        if message != "" {
            let alert = UIAlertController(title: top, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okayButton)
            present(alert, animated: true, completion: nil)
            return
        }else{
            let realm = try! Realm()
            
            let date : Date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyyMMddHHmmssSSS"
            
            let spotModel = SpotModel()
            var nextSegue = ""

            spotModel.spot_name = nameTextField.text!
            spotModel.comment = commentTextField.text!
            spotModel.image_A = image1Path
            spotModel.image_B = image2Path
            spotModel.image_C = image3Path
            
            if spotData.spot_id == 0{
                spotModel.spot_id = Int(format.string(from: date))!
                spotModel.latitude = lat
                spotModel.longitude = lng
                spotModel.datetime = date
                nextSegue = "toStartView"
            }else{
                spotModel.spot_id = spotData.spot_id
                spotModel.latitude = spotData.latitude
                spotModel.longitude = spotData.longitude
                spotModel.datetime = spotData.datetime
                nextSegue = "changeSpotListView"
            }
            
            try! realm.write() {
                realm.add(spotModel, update: true)
            }
            
            print(realm.objects(SpotModel.self))
            
            performSegue(withIdentifier: nextSegue, sender: nil)
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
        
        let spotData : ListSpotModel =
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
            //UIApplication.shared.openURL(url as URL)
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        /*let tapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(imageTapped))
        
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 1:
                spotImageView1!.isUserInteractionEnabled = true
                spotImageView1!.addGestureRecognizer(tapGestureRecognizer)
                self.view.addSubview(spotImageView1!)
                break
            case 2:
                spotImageView2!.isUserInteractionEnabled = true
                spotImageView2!.addGestureRecognizer(tapGestureRecognizer)
                self.view.addSubview(spotImageView2!)
                break
            case 3:
                spotImageView3!.isUserInteractionEnabled = true
                spotImageView3!.addGestureRecognizer(tapGestureRecognizer)
                self.view.addSubview(spotImageView3!)
                break
            default:
                break
            }
        }*/
        
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 1:
                selectImgNum = tag
                break
            case 2:
                selectImgNum = tag
                break
            case 3:
                selectImgNum = tag
                break
            default:
                selectImgNum = 0
                break
            }
        }
        
        if(selectImgNum != 0) {
            checkPermission()
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                /*print("present Start")
                 let imagePicker = UIImagePickerController()
                 imagePicker.delegate = self
                 imagePicker.sourceType = .photoLibrary
                 imagePicker.allowsEditing = true
                 present(imagePicker, animated: true, completion: nil)*/
                let ipc = UIImagePickerController()
                ipc.delegate = self
                ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
                //編集を可能にする
                ipc.allowsEditing = false
                self.present(ipc,animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    @objc
    fileprivate func imageTapped(){
        /*checkPermission()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            /*print("present Start")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)*/
            let ipc = UIImagePickerController()
            ipc.delegate = self
            ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //編集を可能にする
            ipc.allowsEditing = true
            self.present(ipc,animated: true, completion: nil)
        }*/
    }
    
    // アルバム(Photo liblary)の閲覧権限の確認をするメソッド
    func checkPermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("auth")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("not Determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        }
    }
    
    /*func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // 選択した画像・写真を取得し、imageViewに表示
        if let info = editingInfo, let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            spotImageView1.image = editedImage
        }else{
            spotImageView1.image = image
        }
        
        // フォトライブラリの画像・写真選択画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //編集機能を表示させたい場合
        //UIImagePickerControllerEditedImageはallowsEditingをYESにした場合に用いる。
        //allowsEditingで指定した範囲を画像として取得する事ができる。
        //UIImagePickerControllerOriginalImageはallowsEditingをYESにしていたとしても編集機能は表示されない。
        /*if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            //画像を設定する
            imageView.image = image
        }*/
        
        //編集機能を表示させない場合
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let imageUrl = info[UIImagePickerControllerReferenceURL] as? NSURL
        
        switch selectImgNum {
        case 1:
            spotImageView1.image = image
            image1Path = (imageUrl?.absoluteString)!
            break
        case 2:
            spotImageView2.image = image
            image2Path = (imageUrl?.absoluteString!)!
            break
        case 3:
            spotImageView3.image = image
            image3Path = (imageUrl?.absoluteString)!
            break
        default:
            break
        }
        
        dismiss(animated: true,completion: nil)
    }
    
    /*@IBAction func tappedSelectSpotButton(_ sender: Any) {
        goToSelectSpot()
    }
    
    func goToSelectSpot(){
        self.performSegue(withIdentifier: "goSelectSpot", sender:spotDataList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! SelectSpotViewController
        nextViewController.spotDataList = sender as! [ListSpotModel]
    }*/
    
    
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
