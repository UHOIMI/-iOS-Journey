//
//  SpotListViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/10.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class SpotListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate{
    
      private var tabBar:TabBar!
    
    var spotDataList : [ListSpotModel] = []
    var spotNameList : [String] = []
    
    @IBOutlet weak var spotTableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
            spotNameList.append(_sm.spot_name + "\n" + format.string(from: _sm.datetime))
            
        }
        
        createTabBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return spotNameList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel!.text = spotNameList[indexPath.row]
        print("selectTableは通過")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "toDetailSpotView", sender:spotDataList[indexPath.row])
        
    }
    
    @IBAction func tappedSortButton(_ sender: Any) {
        
        spotDataList.reverse()
        spotNameList.reverse()
        
        spotTableView.reloadData()
        
        if(sortButton.currentTitle == "昇順"){
            sortButton.setTitle("降順", for: .normal)
        }else{
            sortButton.setTitle("昇順", for: .normal)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! DetailSpotViewController
        nextViewController.spotData = sender as! ListSpotModel
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
