//
//  HomeViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/12/11.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIScrollViewDelegate, UITabBarDelegate {


  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var userIconImageView: UIButton!
  @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var userIconButton: UIButton!
  @IBOutlet weak var regionImageScroll: UIScrollView!
  @IBOutlet weak var newScroll: UIScrollView!
  @IBOutlet weak var generationScroll: UIScrollView!
  
  
  //let buttonImageDefault :UIImage? = UIImage(named:"no-image.png")
  let buttonImageSelected :UIImage? = UIImage(named:"pen")
  
  var didPrepareMenu = false
  let tabImageWidth:CGFloat = 160
  
  private var pageControl: UIPageControl!
  private var generationPageControl: UIPageControl!
  private var tabBar:TabBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let titleView = UIImageView(frame : CGRect(x:0, y: 0, width:30, height:30))
    titleView.image = UIImage(named: "journey.png")
    titleView.contentMode = .scaleAspectFit
    self.navigationItem.titleView = titleView

    let rightButton: UIButton = UIButton()
    rightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    rightButton.setImage(UIImage(named: "pen"), for: .normal)
    rightButton.addTarget(self, action: #selector(HomeViewController.buttonTapped(sender:)), for: .touchUpInside)
    postBarButtonItem.customView = rightButton
    postBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
    postBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
  
    userIconImageView.imageView?.layer.cornerRadius = 44 * 0.5
    userIconImageView.imageView?.clipsToBounds = true
    
    let page = 3
    let width = self.view.frame.width
    let height : CGFloat = 150
    
    newScroll.isPagingEnabled = true
    newScroll.delegate = self
    newScroll.contentSize = CGSize(width: CGFloat(page) * width, height: 0)
    
    generationScroll.isPagingEnabled = true
    generationScroll.delegate = self
    generationScroll.contentSize = CGSize(width: CGFloat(page) * width, height: 0)
    
    for i in 0 ..< page {
      let newPlanView = TopView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
      newPlanView.planImageView.image = UIImage(named: "no-image.png")
      newPlanView.planUserIconImageView.image = UIImage(named: "no-image.png")
      newPlanView.planUserIconImageView.layer.cornerRadius = 40 * 0.5
      newPlanView.planUserIconImageView.clipsToBounds = true
      newPlanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "newPlanTapped:"))
      newScroll.addSubview(newPlanView)
      
      let generationPlanView = TopView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
      generationPlanView.planImageView.image = UIImage(named: "no-image.png")
      generationPlanView.planUserIconImageView.image = UIImage(named: "no-image.png")
      generationPlanView.planUserIconImageView.layer.cornerRadius = 40 * 0.5
      generationPlanView.planUserIconImageView.clipsToBounds = true
      generationScroll.addSubview(generationPlanView)

//      let label:UILabel = UILabel()
//      label.frame = CGRect(x: CGFloat(i) * width + width/2 - 60, y: height/2 - 40, width: 120, height: 150)
//      label.textAlignment = NSTextAlignment.center
//      label.text = "\(i+1)つ目のページ"
//      newScroll.addSubview(label)
    }
    pageControl = UIPageControl()
    pageControl.frame = CGRect(x:0, y:newScroll.frame.origin.y + 150, width:width, height:50)
    pageControl.backgroundColor = UIColor.white
    pageControl.pageIndicatorTintColor = UIColor.gray
    pageControl.currentPageIndicatorTintColor = UIColor.black
    pageControl.numberOfPages = page
    pageControl.currentPage = 0
    
    generationPageControl = UIPageControl()
    generationPageControl.frame = CGRect(x:0, y:generationScroll.frame.origin.y + 150, width:width, height:50)
    generationPageControl.backgroundColor = UIColor.white
    generationPageControl.pageIndicatorTintColor = UIColor.gray
    generationPageControl.currentPageIndicatorTintColor = UIColor.black
    generationPageControl.numberOfPages = page
    generationPageControl.currentPage = 0
    
    self.subView.addSubview(pageControl)
    self.subView.addSubview(generationPageControl)

    createTabBar()

  }
  
  override func viewDidLayoutSubviews() {
    
    if didPrepareMenu { return }
    didPrepareMenu = true
    
    regionImageScroll.delegate = self
    
    let regionList = ["北海道", "東北", "関東", "中部", "近畿", "中国", "四国", "九州"]
    let imageList = ["関東","関東","no-image.png","no-image.png","no-image.png","no-image.png","no-image.png","no-image.png"]
    
    let tabImageHeight:CGFloat = regionImageScroll.frame.height
    let dummyImageWidth = regionImageScroll.frame.size.width/4 - tabImageWidth/2
    let headDummyImage = UIImageView()
    let rect:CGRect = CGRect(x:0, y:0, width:dummyImageWidth, height:tabImageHeight)
    headDummyImage.frame = rect
    
    var imageOriginX:CGFloat = dummyImageWidth
    
    for imageName in imageList{
      
      let imageView = UIImageView()
      imageView.frame = CGRect(x:imageOriginX, y:0, width:tabImageWidth, height:tabImageHeight)
      
      let image = UIImage(named: imageName)
      imageView.image = image
      
      regionImageScroll.addSubview(imageView)
      imageOriginX += tabImageWidth + dummyImageWidth
      
    }
    
    let tailImage = UIImageView()
    tailImage.frame = CGRect(x: imageOriginX, y: 0, width: dummyImageWidth, height: tabImageHeight)
    regionImageScroll.addSubview(tailImage)
    imageOriginX += dummyImageWidth
    regionImageScroll.contentSize = CGSize(width: imageOriginX, height: tabImageHeight)
    
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if fmod(scrollView.contentOffset.x, scrollView.frame.width) == 0 {
      if(scrollView.tag == 1){
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
      }else if(scrollView.tag == 2){
        generationPageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
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
      performSegue(withIdentifier: "toTimelineView", sender: nil)
    case 4:
      performSegue(withIdentifier: "toDetailUserView", sender: nil)
    default : return
    }
  }
  
  @IBAction func tappedUserIcon(_ sender: Any) {
    performSegue(withIdentifier: "toDetailUserView", sender: nil)
  }
  
  @objc func buttonTapped(sender : AnyObject) {
    performSegue(withIdentifier: "toPostView", sender: nil)
  }
  
  func newPlanTapped(sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "toDetailPlanView", sender: nil)
  }
  
  func generationPlanTapped(sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "toDetailPlanView", sender: nil)
  }
  
  @IBAction func tappedPutSpot(_ sender: Any) {
    performSegue(withIdentifier: "toPutSpotView", sender: nil)
  }
  
  
}
