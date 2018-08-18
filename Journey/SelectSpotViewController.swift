//
//  SelectSpotViewController.swift
//  Journey
//
//  Created by 猪岡勝生 on 2018/08/10.
//  Copyright © 2018年 Swift-Biginners. All rights reserved.
//

import UIKit
//import GoogleMaps
//import GooglePlaces
//import GooglePlacePicker

class SelectSpotViewController: UIViewController /*, UITableViewDelegate, UITableViewDataSource*/{
//
//  var spotDataList : [SpotData] = []
//  var spotNameList : [String] = []
//  var selectSpotDataList : [SpotData] = []
//  var selectSpotNameList : [String] = []
//  var placePicker: GMSPlacePicker?
//
//  let top = "エラー"
//  let message = "スポットが選択されていません"
//  let okText = "OK"
//
//  var fmt = DateFormatter()
//
//  @IBOutlet weak var selectSpotTable: UITableView!
//  @IBOutlet weak var goMapButton: UIButton!
//  @IBOutlet weak var userSpotTable: UITableView!
//  @IBOutlet weak var sortButton: UIButton!
//
//  override func viewDidLoad() {
//
//    super.viewDidLoad()
//    fmt.dateFormat = "yyyy/MM/dd"
//    for _sd in spotDataList{
//      spotNameList.append(fmt.string(from: _sd.date) + "：" + _sd.name)
//    }
//    // Do any additional setup after loading the view.
//  }
//
//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//  }
//
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//    if tableView.tag == 1 {
//      return selectSpotNameList.count
//    }else if tableView.tag == 2 {
//      return spotNameList.count
//    }
//    return 0
//
//  }
//
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    if tableView.tag == 1 {
//      let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath)
//      cell.textLabel!.text = selectSpotNameList[indexPath.row]
//      //selectSpotNameList.remove(at: indexPath.row)
//      //tableView.deleteRows(at: [indexPath], with: .fade)
//      return cell
//    }else if tableView.tag == 2 {
//      let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
//      print("test:" + spotNameList[indexPath.row])
//      cell.textLabel!.text = spotNameList[indexPath.row]
//      return cell
//    }
//
//    let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
//    return cell
//  }
//
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    //tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    if(tableView.tag == 1){
//      print(indexPath)
//    }
//
//    if(tableView.tag == 2){
//      selectSpotNameList.append(spotNameList[indexPath.row])
//      selectSpotDataList.append(spotDataList[indexPath.row])
//      //selectSpotNameList.insert(spotNameList[indexPath.row], at: 1)
//
//      let selectIndexPath = IndexPath(row : selectSpotNameList.count - 1,section : 0)
//      selectSpotTable.insertRows(at: [selectIndexPath], with: .automatic)
//
//      //userSpotTable.reloadData()
//      //var selectIndexPath : IndexPath = [0,selectSpotNameList.count]
//      //userSpotTable.insertRows(at: [selectIndexPath], with: .automatic)
//
//      spotNameList.remove(at: indexPath.row)
//      tableView.deleteRows(at: [indexPath], with: .fade)
//      //tableView.deleteRowsAtIndexPaths([IndexPath(forRow: indexPath.row, inSection: 0)],withRowAnimation: UITableViewRowAnimation.Fade)
//      //userSpotTable.reloadData()
//    }
//  }
//
//
//  @IBAction func pickPlace(_ sender: UIButton) {
//    let config = GMSPlacePickerConfig(viewport: nil)
//    placePicker = GMSPlacePicker(config: config)
//    //placePicker.delegate = self as! GMSPlacePickerViewControllerDelegate
//    //present(placePicker, animated: true, completion: nil)
//
//    //placePicker?.pickPlaceWithCallback({ (place: GMSPlace?,error: NSError?) -> Void in
//    placePicker?.pickPlace(callback: { (place,error) -> Void in
//      var name = ""
//      var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//
//      if error != nil {
//        name = "エラー"
//        return
//      }
//
//      if place != nil {
//        name = (place?.name)!
//        print(name)
//        coordinate = (place?.coordinate)!
//        print(coordinate)
//        self.selectSpotNameList.append(name)
//        self.selectSpotDataList.append(SpotData(la: coordinate.latitude,lo: coordinate.longitude, na: name))
//        let selectIndexPath = IndexPath(row : self.selectSpotNameList.count - 1,section : 0)
//        self.selectSpotTable.insertRows(at: [selectIndexPath], with: .automatic)
//      } else {
//        name = "No place selected"
//      }
//    })
//  }
//  // To receive the results from the place picker 'self' will need to conform to
//  // GMSPlacePickerViewControllerDelegate and implement this code.
//  /*func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//   // Dismiss the place picker, as it cannot dismiss itself.
//   viewController.dismiss(animated: true, completion: nil)
//
//   print("Place name \(place.name)")
//   print("Place address \(place.formattedAddress)")
//   print("Place attributions \(place.attributions)")
//   }
//
//   func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
//   // Dismiss the place picker, as it cannot dismiss itself.
//   viewController.dismiss(animated: true, completion: nil)
//
//   print("No place selected")
//   }*/
//
//
//  @IBAction func tappedMapButton(_ sender: Any) {
//    if selectSpotNameList.count == 0 {
//      let alert = UIAlertController(title: top, message: message, preferredStyle: UIAlertControllerStyle.alert)
//      let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.cancel, handler: nil)
//      alert.addAction(okayButton)
//      present(alert, animated: true, completion: nil)
//      return
//    }
//    goMap()
//  }
//
//  func goMap() {
//    self.performSegue(withIdentifier: "goMap", sender:selectSpotDataList)
//  }
//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    let nextViewController = segue.destination as! MapViewController
//    nextViewController.spotDataList = sender as! [SpotData]
//  }
//
//
//  @IBAction func tappedSortButton(_ sender: Any) {
//
//    spotDataList.reverse()
//    spotNameList.reverse()
//
//    userSpotTable.reloadData()
//
//    if(sortButton.currentTitle == "昇順"){
//      sortButton.setTitle("降順", for: .normal)
//    }else{
//      sortButton.setTitle("昇順", for: .normal)
//    }
//
//    /*var tempSpotDataList : [SpotData] = []
//     var tempSpotNameList : [String] = []
//
//     for _num in self.spotDataList.count - 1...0 {
//     tempSpotDataList.append(spotDataList[_num])
//     }
//
//     spotDataList = tempSpotDataList
//
//     for _num in self.spotNameList.count - 1...0 {
//     tempSpotNameList.append(spotNameList[_num])
//     }
//
//     spotNameList = tempSpotNameList*/
//
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
