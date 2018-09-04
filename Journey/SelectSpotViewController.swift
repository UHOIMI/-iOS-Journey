//
//  SelectSpotViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/10.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class SelectSpotViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,UITabBarDelegate{
    
    private var tabBar:TabBar!
    
    var spotDataList : [ListSpotModel] = []
    var spotNameList : [String] = []
    var selectSpotDataList : [ListSpotModel] = []//現状PotViewControllerに渡す予定のデータリスト
    var selectSpotNameList : [String] = []
    var grayList : [Bool] = []
    
    var placePicker: GMSPlacePicker?
    
    let top = "エラー"
    let message = "スポットが選択されていません"
    let okText = "OK"
    
    var fmt = DateFormatter()
    var changeColorRow = -1
    
    let postViewController = PostViewController()
    
    @IBOutlet weak var selectSpotTable: UITableView!
    @IBOutlet weak var userSpotTable: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fmt.dateFormat = "yyyy/MM/dd"
        /*for _sd in spotDataList{
         spotNameList.append(fmt.string(from: _sd.date) + "：" + _sd.name)
         }*/
        
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm "
        
        let realm = try! Realm()
        let spotModelList = realm.objects(SpotModel.self)
        for _sm in spotModelList {
            let listSpotModel = ListSpotModel()
            listSpotModel.spot_id = _sm.spot_id
            listSpotModel.spot_name = _sm.spot_name
            listSpotModel.latitude = _sm.latitude
            listSpotModel.longitude = _sm.longitude
            listSpotModel.comment = _sm.comment
            listSpotModel.datetime = _sm.datetime
            listSpotModel.image_A = _sm.image_A
            listSpotModel.image_B = _sm.image_B
            listSpotModel.image_C = _sm.image_C
            spotDataList.append(listSpotModel)
            //spotNameList.append(_sm.spot_name)
            spotNameList.append(_sm.spot_name + "\n" + format.string(from: _sm.datetime))
            grayList.append(false)
        }
        
        createTabBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 1 {
            return selectSpotNameList.count
        }else if tableView.tag == 2 {
            return spotNameList.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath)
            cell.textLabel!.text = String(selectSpotNameList.count + 1) + " : " + selectSpotNameList[indexPath.row]
            var selectName : String = cell.textLabel!.text!
            var pt = "[0-9]* : (.*)"
            
            var matchStrings:[String] = []
            
            do {
                
                let regex = try NSRegularExpression(pattern: pt, options: [])
                let targetStringRange = NSRange(location: 0, length: (selectName as NSString).length)
                
                let matches = regex.matches(in: selectName, options: [], range: targetStringRange)
                
                for match in matches {
                    
                    // rangeAtIndexに0を渡すとマッチ全体が、1以降を渡すと括弧でグループにした部分マッチが返される
                    let range = match.range(at: 1)
                    let result = (selectName as NSString).substring(with: range)
                    
                    matchStrings.append(result)
                }
                cell.textLabel?.text = String(indexPath.row + 1) + " : " + matchStrings[0]
                
            } catch {
                print("error: getMatchStrings")
            }
            
            
            //let ans = selectName.pregReplace(pattern: pt, with: "")
            //selectName.match(pattern: "^([0-9]*):([^/]+)", group: 2)
            print("selectTableは通過")
            return cell
        }else if tableView.tag == 2 {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
            print("test:" + spotNameList[indexPath.row])
            cell.textLabel!.text = spotNameList[indexPath.row]
            cell.textLabel?.numberOfLines = 0;
            print("userTableは通過")
            /*if changeColorRow == indexPath.row{
                cell.textLabel?.textColor = UIColor.gray
            }*/
            if grayList[indexPath.row] == true{
                cell.textLabel?.textColor = UIColor.gray
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }else{
                cell.textLabel?.textColor = UIColor.black
                cell.selectionStyle = UITableViewCellSelectionStyle.default
            }
            return cell
        }
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView.tag == 1){
            print(indexPath)
        }
        
        if(tableView.tag == 2){
            //let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
            /*let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath) as! UITableViewCell*/
            
            if(grayList[indexPath.row] == false){
            
                //selectSpotNameList.append(String(selectSpotNameList.count + 1) + " : " +  spotNameList[indexPath.row])
                selectSpotNameList.append(spotNameList[indexPath.row])
                selectSpotDataList.append(spotDataList[indexPath.row])
                
                let selectIndexPath = IndexPath(row : selectSpotNameList.count - 1,section : 0)
                selectSpotTable.insertRows(at: [selectIndexPath], with: .automatic)
                
                grayList[indexPath.row] = true
                tableView.reloadData()
                
            }
            
            //cell.textLabel?.textColor = UIColor.red
            //cell.backgroundColor = UIColor.red
            //userSpotTable.reloadData()
            //cell.reloadInputViews()
            //changeColorRow = indexPath.row
            
            //tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: UITableViewRowAnimation.fade)
            
            
            /*spotNameList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)*/
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(tableView.tag == 1){
            if editingStyle == .delete {
                
                for (i, value) in spotDataList.enumerated() {
                    if value.spot_id == selectSpotDataList[indexPath.row].spot_id{
                        grayList[i] = false
                    }
                }
                
                selectSpotDataList.remove(at: indexPath.row)
                selectSpotNameList.remove(at: indexPath.row)
                
                userSpotTable.reloadData()
                tableView.deleteRows(at: [indexPath], with: .fade)
                selectSpotTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(tableView.tag == 2){
            return false
        }
        return true
    }
    
    
    @IBAction func pickPlace(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlace(callback: { (place,error) -> Void in
            var name = ""
            var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            
            if error != nil {
                name = "エラー"
                print(error!)
                return
            }
            
            if place != nil {
                name = (place?.name)!
                print(name)
                coordinate = (place?.coordinate)!
                print(coordinate)
                //self.selectSpotNameList.append(String(self.selectSpotNameList.count + 1) + " : " + name)
                self.selectSpotNameList.append(name)
                self.selectSpotDataList.append(ListSpotModel(la: coordinate.latitude,lo: coordinate.longitude, na: name))
                let selectIndexPath = IndexPath(row : self.selectSpotNameList.count - 1,section : 0)
                self.selectSpotTable.insertRows(at: [selectIndexPath], with: .automatic)
                self.selectSpotTable.reloadData()
            } else {
                name = "No place selected"
            }
        })
    }
    
    /*@IBAction func tappedMapButton(_ sender: Any) {
     if selectSpotNameList.count == 0 {
     let alert = UIAlertController(title: top, message: message, preferredStyle: UIAlertControllerStyle.alert)
     let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
     alert.addAction(okayButton)
     present(alert, animated: true, completion: nil)
     return
     }
     goMap()
     }
     
     func goMap() {
     self.performSegue(withIdentifier: "goMap", sender:selectSpotDataList)
     }*/
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     let nextViewController = segue.destination as! MapViewController
     nextViewController.spotDataList = sender as! [SpotData]
     }*/
    
    
    @IBAction func tappedSortButton(_ sender: Any) {
        
        spotDataList.reverse()
        spotNameList.reverse()
        grayList.reverse()
        
        userSpotTable.reloadData()
        
        if(sortButton.currentTitle == "昇順"){
            sortButton.setTitle("降順", for: .normal)
        }else{
            sortButton.setTitle("昇順", for: .normal)
        }
        
    }
    
    @IBAction func tappedMapButton(_ sender: Any) {
        if selectSpotNameList.count == 0 {
            let alert = UIAlertController(title: top, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okayButton)
            present(alert, animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "changePostView", sender:selectSpotDataList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "changePostView"){
            print(selectSpotDataList)
            print(selectSpotNameList)
            for i in 0 ... selectSpotNameList.count - 1{
                postViewController.count += 1
                postViewController.updateTableView(name: selectSpotNameList[i], list:selectSpotDataList[i])
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
