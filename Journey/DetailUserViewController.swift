//
//  DetailUserViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/06.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class DetailUserViewController: UIViewController, UITabBarDelegate {
  
  private var tabBar:TabBar!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var headerImageView: UIImageView!
  @IBOutlet weak var userNameTextView: UILabel!
  @IBOutlet weak var userGenderTextView: UILabel!
  @IBOutlet weak var userGenerationTextView: UILabel!
  @IBOutlet weak var userCommentTextView: UILabel!
  
  var imgView:UIImageView!
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      if myFrameSize.height >= 6{
        //scrollViewsetScrollEnabled
        scrollView.isScrollEnabled = true
      }
      
      self.imgView = UIImageView()
      self.imgView.frame = CGRect(x: 30, y: headerImageView.frame.origin.y + headerImageView.frame.height, width: 100, height: 100)
      self.imgView.image = UIImage(named: "no-image.png")
      self.imgView.frame.origin.y -= self.imgView.frame.height / 2
      
      //headerImageView.contentMode = UIView.ContentMode.scaleAspectFit
      headerImageView.image = UIImage(named: "mountain")
      
      // 角を丸くする
      self.imgView.layer.cornerRadius = 100 * 0.5
      self.imgView.clipsToBounds = true
      
      subView.addSubview(self.imgView)

      userCommentTextView.text = "俺は泥棒である。本日も、とあるお宅にお邪魔した。――しかし。靴には穴が開いている。服にも穴が開いている。ガスは止められ、電気もつかない。通帳を見つけた。残高十八円だった。子供の部屋で見つけたのは、小さな手紙。『サンタさんへおかあさんに、きれいなドレスをください』俺は自分の財布から、福沢諭吉を一枚取り出した。そして、手紙の下に書き加えた。『サンタさんはセンスがないので、君が好きなのを選んであげてね』"
      userCommentTextView.numberOfLines = 0
      userCommentTextView.sizeToFit()
      
      createTabBar()

        // Do any additional setup after loading the view.
    }
  
  
  @IBAction func tappedEditButton(_ sender: Any) {
    performSegue(withIdentifier: "toEditUserView", sender: nil)
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
