//
//  DetailUserViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/11/06.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
import RealmSwift

class DetailUserViewController: UIViewController, UITabBarDelegate {
  
  private var tabBar:TabBar!
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var subView: UIView!
  @IBOutlet weak var headerImageView: UIImageView!
  @IBOutlet weak var userNameTextView: UILabel!
  @IBOutlet weak var userGenderTextView: UILabel!
  @IBOutlet weak var userGenerationTextView: UILabel!
  @IBOutlet weak var userCommentTextView: UILabel!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var spotListButton: UIButton!
  @IBOutlet weak var logoutButton: UIButton!
  @IBOutlet weak var pastLabel: UILabel!
  
  var timelineFlag = 0
  
  let globalVar = GlobalVar.shared
  var editFlag = true
  var userId = ""
  var userName = ""
  var userGeneration = ""
  var userGender = ""
  var userComment = ""
  var userIcon = UIImage()
  var userHeader = UIImage()
  
  
  var imgView:UIImageView!
  let myFrameSize:CGSize = UIScreen.main.bounds.size
  
    override func viewDidLoad() {
      self.navigationItem.hidesBackButton = true
        super.viewDidLoad()

      if (myFrameSize.height >= 667){
        //scrollViewsetScrollEnabled
        scrollView.isScrollEnabled = false
      }
      self.headerImageView.image = UIImage(named:"no-image.png")!
      self.imgView = UIImageView()
      imgView.frame = CGRect(x: 30, y: headerImageView.frame.origin.y + (UIScreen.main.bounds.size.width / 3), width: 100, height: 100)
      imgView.frame.origin.y -= self.imgView.frame.height / 2
      imgView.image = UIImage(named:"no-image.png")!
      // 角を丸くする
      self.imgView.layer.cornerRadius = 100 * 0.5
      self.imgView.clipsToBounds = true
      
      if(!editFlag){
        editButton.title = ""
        editButton.isEnabled = false
        spotListButton.isHidden = true
        logoutButton.isHidden = true
        subView.addSubview(self.imgView)
        getUser()
        userCommentTextView.text = globalVar.userComment
        userCommentTextView.numberOfLines = 0
        userCommentTextView.sizeToFit()
      }else{
        imgView.image = globalVar.userIcon
        headerImageView.image = globalVar.userHeader
        subView.addSubview(self.imgView)
        userGenderTextView.text = globalVar.userGender
        userGenerationTextView.text = "\(globalVar.userGeneration)"
        userNameTextView.text = globalVar.userName
        userCommentTextView.text = globalVar.userComment
        userCommentTextView.numberOfLines = 0
        userCommentTextView.sizeToFit()
      }
      
      let userPlanView = TopView(frame: CGRect(x: 16, y: pastLabel.frame.origin.y + pastLabel.frame.size.height + 8, width: UIScreen.main.bounds.size.width - 32, height: 150))
      userPlanView.backgroundColor = UIColor.red
      userPlanView.planUserIconImageView.image = globalVar.postUserImage
      userPlanView.planImageView.image = globalVar.postSpotImage
      userPlanView.planNameLabel.text = globalVar.postPlanTitle
      userPlanView.planUserNameLabel.text = globalVar.postUserName
      userPlanView.planSpotNameLabel1.text = globalVar.postSpotNameA
      userPlanView.planDateLabel.text = globalVar.postDate
      userPlanView.planUserIconImageView.layer.cornerRadius = 40 * 0.5
      userPlanView.planUserIconImageView.clipsToBounds = true
      userPlanView.planUserIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.planUserImageViewTapped(_:))))
      userPlanView.planUserIconImageView.isUserInteractionEnabled = true
      userPlanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewController.generationPlanTapped(_ :))))
      userPlanView.layer.cornerRadius = 5
      userPlanView.layer.masksToBounds = true
      subView.addSubview(userPlanView)
      subView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
      
      createTabBar()

        // Do any additional setup after loading the view.
    }
  
  override func viewDidAppear(_ animated: Bool) {
    print("headerImageView.frame.origin.y : ", headerImageView.frame.origin.y)
    print("headerImageView.frame.height : ", headerImageView.frame.height)
    print("HIVheaderImageView.frame.origin.y : ", headerImageView.bounds.origin.y)
    print("HIVheaderImageView.frame.height : ", headerImageView.bounds.height)
  }
  
  
  @IBAction func tappedEditButton(_ sender: Any) {
    performSegue(withIdentifier: "toEditUserView", sender: nil)
  }
  
  struct UserData : Codable{
    let status : Int
    let record : [Record]?
    let message : String?
    enum CodingKeys: String, CodingKey {
      case status
      case record
      case message
    }
    struct Record : Codable{
      let userId : String
      let userName : String
      let generation : Int
      let gender : String
      let comment : String?
      let user_icon : String?
      let user_header : String?
      enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case generation = "generation"
        case gender = "gender"
        case comment = "comment"
        case user_icon = "user_icon"
        case user_header = "user_header"
      }
    }
  }
  
  func getUser(){
//    var text = "http://\(globalVar.ipAddress)/api/v1/user/find?user_id=\(userId)"
    let url = URL(string: "http://\(globalVar.ipAddress)/api/v1/users/find?user_id=\(userId)")
//    text = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//    //    let decodedString:String = text.removingPercentEncoding!
//    print("URLのテスト", text)
//    let url = URL(string: text)!
    let request = URLRequest(url: url!)
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
      if error == nil, let data = data, let response = response as? HTTPURLResponse {
        // HTTPヘッダの取得
        print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
        // HTTPステータスコード
        print("statusCode: \(response.statusCode)")
        print(String(data: data, encoding: String.Encoding.utf8) ?? "")
        let userData = try? JSONDecoder().decode(UserData.self, from: data)
        if(userData!.status == 200){
          for i in 0 ... (userData?.record?.count)! - 1{
            self.userName = (userData?.record![i].userName)!
            self.userComment = (userData?.record![i].comment)!
            self.userGeneration = (userData?.record![i].generation)!.description
            self.userGender = (userData?.record![i].gender)!
            if(userData?.record![i].user_icon != nil && (userData?.record![i].user_icon)! != ""){
              let url = URL(string: (userData?.record![i].user_icon)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.userIcon = image!
            }else{
              self.userIcon = UIImage(named:"no-image.png")!
            }
            if(userData?.record![i].user_header != nil && (userData?.record![i].user_header)! != ""){
              let url = URL(string: (userData?.record![i].user_header)!)!
              let imageData = try? Data(contentsOf: url)
              let image = UIImage(data:imageData!)
              self.userHeader = image!
            }else{
              self.userHeader = UIImage(named:"no-image.png")!
            }
          }
          
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.userNameTextView.text = self.userName
            self.userGenderTextView.text = self.userGender
            self.userCommentTextView.text = self.userComment
            self.userGenerationTextView.text = "\(self.userGeneration)代"
            self.imgView.image = self.userIcon
            self.headerImageView.image = self.userHeader
          }
        }else{
          print("status",userData!.status)
        }
      }
    }.resume()
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
      print("４")
    default : return
      
    }
  }
  
  @IBAction func tappeddSpotList(_ sender: Any) {
    performSegue(withIdentifier: "toSpotListView", sender: nil)
  }
  
  
  @IBAction func tappedLogout(_ sender: Any) {
    let realm = try! Realm()
    let users = realm.objects(UserModel.self)
    
    for _user in users{
      try! realm.write() {
        realm.delete(_user)
      }
    }
    //performSegue(withIdentifier: "toIndexView", sender: nil)
  }
  @IBAction func tappedUserPostListButton(_ sender: Any) {
    timelineFlag = 1
    performSegue(withIdentifier: "toTimelineView", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if(segue.identifier == "toTimelineView" && timelineFlag == 1){
      let nextViewController = segue.destination as! TimelineViewController
      nextViewController.detailUserFlag = timelineFlag
      nextViewController.detailUserId = globalVar.userId
    }
  }
  
}
