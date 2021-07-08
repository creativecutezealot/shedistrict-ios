//  Preferences_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/8/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import DropDown
import CZPicker


//var dictPreferecenes = [String:String]()

//
//class Preferences_ViewController: UIViewController {
//    @IBOutlet weak var tbl_preference:UITableView!
//
//    var dictPrefSelected = ["Age":"","Nationality":"","Ethnicity":"","Religion":"","Distance":"","Education":"","Relationship_Status":"","Sexual_Orientation":"","Has_Kids?":"","Drinking_Habits":"","Smoking_Habits":"","Political_Affiliation":""]
//
//    let arr_preferences = ["Age","Ethnicity","Nationality","Religion","Distance","Education","Relationship Status","Sexual Orientation","Has Kids?","Drinking Habits","Smoking Habits","Political Affiliation"]
//
//    var arrCZPickerView = [String]()
//    var titleSelected = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        preference.removeAll()
//        dictPreferecenes = ["Age":"","Nationality":"","Ethnicity":"","Religion":"","Distance":"","Education":"","Relationship_Status":"","Sexual_Orientation":"","Has_Kids?":"","Drinking_Habits":"","Smoking_Habits":"","Political_Affiliation":""]
//
//        func_get_preference()
//    }
//
//    @IBAction func btnCheckMark(_ sender:UIButton) {
//        var arrPreference = [String]()
//
//        print(dictPreferecenes)
//
//        for (key,value) in dictPreferecenes {
//            arrPreference.append(value)
//        }
//
//        if arrPreference.isEmpty {
//            return
//        }
//
////        btn_back("")
////        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
////            NotificationCenter.default.post(name:NSNotification.Name (rawValue:"preference"), object: nil)
////        }
//    }
//
//    func func_get_preference() {
//        let hud = KRProgressHUD.showOn(self)
//        hud.show()
//        APIFunc.getAPI("get_preference", [:]) { (json,status,message)  in
//            DispatchQueue.main.async {
//                hud.dismiss()
//
//                let status = return_status(json.dictionaryObject!)
//                switch status {
//                case .success:
//                    let decoder = JSONDecoder()
//                    if let jsonData = json[result_resp].description.data(using: .utf8) {
//                        do {
//                            preference = try decoder.decode([Preference].self, from: jsonData)
//                            self.tbl_preference.reloadData()
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
//                case .fail:
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//                        hud.showError(withMessage: "\(json["message"])")
//                    })
//                case .error_from_api:
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//                        hud.showError(withMessage:"error_message")
//                    })
//                }
//            }
//        }
//    }
//
//}
//
//extension Preferences_ViewController:UITableViewDelegate,UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return preference.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Preferences_TableViewCell
//
//        cell.lbl_preference_name.text = preference[indexPath.row].preference
//        cell.btnSelect.tag = indexPath.row
//        cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let animation = AnimationFactory.makeSlideIn(duration:0.25, delayFactor:0.01)
//        let animator = Animator(animation: animation)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
//    }
//
//    @IBAction func btnSelect(_ sender:UIButton) {
//        var arr_drop_down = [String]()
//        let strPreferenceKey = preference[sender.tag].preference
//        if strPreferenceKey.lowercased() == "age" || strPreferenceKey.lowercased() == "distance"{
//         funcSliderRange(strPreferenceKey.lowercased())
//        } else {
//            for pre in preference[sender.tag].values {
//                arr_drop_down.append(pre.valueName)
//            }
//
//            arrCZPickerView = arr_drop_down
//            titleSelected = strPreferenceKey
//            if arrCZPickerView.count > 0 {
//                showWithMultipleSelections()
//            }
//
//        }
//    }
//
//    func funcSliderRange(_ sliderType:String) {
//        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
//        let sliderRange_VC = storyboard.instantiateViewController(withIdentifier: "SliderRangeVC") as! SliderRangeVC
//        sliderRange_VC.sliderType = sliderType
//
//        self.addChild(sliderRange_VC)
//
//        sliderRange_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
//
//        self.view.addSubview(sliderRange_VC.view)
//        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
//            sliderRange_VC.view.transform = .identity
//        })
//
//    }
//
//}
//
//
//
//extension Preferences_ViewController:CZPickerViewDelegate, CZPickerViewDataSource {
//    func showWithMultipleSelections() {
//        let picker = CZPickerView(headerTitle: titleSelected, cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
//        picker!.delegate = self
//        picker!.dataSource = self
//        picker!.needFooterView = false
//        picker!.allowMultipleSelection = true
//        picker!.show()
//
//        let arrPref = dictPrefSelected[titleSelected]?.components(separatedBy: ",")
//        if !dictPrefSelected[titleSelected]!.isEmpty {
//            var prefSelectedIndex = [Int]()
//            for pref in arrPref! {
//                prefSelectedIndex.append(arrCZPickerView.firstIndex(of:pref)!)
//            }
//
//            picker?.setSelectedRows(prefSelectedIndex)
//        }
//    }
//
////    func czpickerView(pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
////        if pickerView == pickerWithImage {
////            return fruitImages[row]
////        }
////        return nil
////    }
//
//    func numberOfRows(in pickerView: CZPickerView!) -> Int {
//        return arrCZPickerView.count
//    }
//
//    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
//        return arrCZPickerView[row]
//    }
//
//    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [Any]!) {
//        var valueSelected = ""
//
//        for row in 0..<rows.count {
//            let i = rows[row] as! Int
//            valueSelected = row == 0 ? arrCZPickerView[i] : valueSelected+","+arrCZPickerView[i]
//        }
//        dictPrefSelected[titleSelected] = valueSelected
//        dictPreferecenes[titleSelected] = valueSelected
//    }
//
//}


