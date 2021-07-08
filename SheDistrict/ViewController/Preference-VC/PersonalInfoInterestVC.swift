//  PersonalInfoInterestVC.swift
//  SheDistrict
//  Created by appentus on 3/19/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import MultiSlider

var arrPersonalInfoValue = [String]()
var arrInterestInfoValue = [String]()
var is_interests = false

class PersonalInfoInterestVC: UIViewController {
    @IBOutlet weak var tbl_preference:UITableView!
    @IBOutlet var btn_personal_info:[UIButton]!
    
    var arrSelect = [Bool]()
    var selectedCheckboxArr = [[Bool]]()
    var isValidNationality = false
    
    var arrSearched = [String]()
    var arrForSearch = [String]()
    
    let dropNationality = DropDown()
        
    var user_idFriend = ""
    
    var dictPrefUpdate = [String:String]()
    
    var dictPrefUpdateInterest = [String:String]()
    var selectedInterestCheckboxArr = [[Bool]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        is_interests = false
        
        for i in 0..<btn_personal_info.count {
            btn_personal_info[i].tag = i+1
            btn_personal_info[i].addTarget(self, action: #selector(btn_personal_info(_:)), for:.touchUpInside)
        }
        
        for i in 0..<btn_personal_info.count {
            if i+1 == 1 {
                btn_personal_info[i].setTitleColor(UIColor .black, for: .normal)
            } else {
                btn_personal_info[i].setTitleColor(UIColor .gray, for: .normal)
            }
        }
        
        var countries: [String] = []
        
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
              
        arrForSearch = countries
        
        preference.removeAll()
        tbl_preference.estimatedRowHeight = 30
        tbl_preference.rowHeight = UITableView.automaticDimension
        
        func_get_preference()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSelectArr(_:)), name: NSNotification.Name("updateSelectArr"), object: nil)
    }
      
    @objc func updateSelectArr(_ sender:NSNotification){
        let object = sender.object as! [Bool]
        let userinfo = sender.userInfo! as NSDictionary
        let tag = userinfo["tag"] as! Int
        self.selectedCheckboxArr[tag] = object
    }
    
    func func_get_preference() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.getAPI("get_preference", [:]) { (json,status,message)  in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            preference = try decoder.decode([Preference].self, from: jsonData)
                            for _ in preference {
                                self.arrSelect.append(false)
                            }
                            
                            self.updateCheckboxBool()
                            
                            self.tbl_preference.reloadData()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case .fail:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage: "\(json["message"])")
                    })
                case .error_from_api:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage:"error_message")
                    })
                }
            }
        }
    }
    
    func updateCheckboxBool() {
        dictPrefUpdate.removeAll()
        selectedCheckboxArr = [[Bool]]()
        let dictPersonalInfo = signUp!.personalInfo.dictionary
        
        for i in 0..<preference.count {
            arrPersonalInfoValue.append("")
            let keyPersonalInfo = preference[i].preference.replacingOccurrences(of:" ", with:"_")
            let infoValue = dictPersonalInfo[keyPersonalInfo] as? String
            
            if preference[i].inputType == "checkbox" || preference[i].inputType == "radio" {
                var localBoolArr = [Bool]()
                
                for j in 0..<preference[i].values.count {
                    if infoValue?.lowercased() == preference[i].values[j].valueName.lowercased() {
                        localBoolArr.append(true)
                        arrPersonalInfoValue[i] = preference[i].values[j].valueName
                    } else {
                        localBoolArr.append(false)
                    }
                }
                self.selectedCheckboxArr.append(localBoolArr)
            } else {
                dictPrefUpdate[keyPersonalInfo] = infoValue
                self.selectedCheckboxArr.append([false])
            }
        }
    }
    
    func updateCheckInterest() {
//        dictPrefUpdate.removeAll()
//        selectedCheckboxArr = [[Bool]]()
        let dictPersonalInfo = signUp!.interestInfo.dictionary
        
        for i in 0..<getInterest.count {
            arrInterestInfoValue.append("")
            let keyPersonalInfo = getInterest[i].interest.replacingOccurrences(of:" ", with:"_")
            let infoValue = dictPersonalInfo[keyPersonalInfo] as? String
            
            if getInterest[i].type == "checkbox" {
                var localBoolArr = [Bool]()
                for j in 0..<getInterest[i].value.count {
                    
                    if infoValue?.lowercased() == getInterest[i].value[j].interestValue.lowercased() {
                        localBoolArr.append(true)
                        arrInterestInfoValue[i] = getInterest[i].value[j].interestValue
                    } else {
                        localBoolArr.append(false)
                    }
                }
                self.selectedInterestCheckboxArr.append(localBoolArr)
            } else {
                dictPrefUpdateInterest[keyPersonalInfo] = infoValue
                self.selectedInterestCheckboxArr.append([false])
            }
        }
    }
    
    @IBAction func btnCancel(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
//    @IBAction func btnCheckMark(_ sender:UIButton) {
//        var dictPrefSelected = [String:String]()
//
//        for i in 0..<selectedCheckboxArr.count {
//            let arrSelectedCheckBox = selectedCheckboxArr[i]
//            let arrPrefValue = preference[i].values
//            var strPrefValue = ""
//
//            for j in 0..<arrSelectedCheckBox.count {
//                if arrSelectedCheckBox[j] {
//                    strPrefValue = strPrefValue.isEmpty ? arrPrefValue[j].valueName : "\(strPrefValue),\(arrPrefValue[j].valueName)"
//                } else {
//                    for (key,value) in dictPrefUpdate {
//                        if key == preference[i].preference {
//                            strPrefValue = value
//                        }
//                    }
//                }
//            }
//
//            if !strPrefValue.isEmpty {
//                dictPrefSelected[preference[i].preference.replacingOccurrences(of:" ", with:"_")] = strPrefValue
//            }
//        }
//
//        if dictPrefSelected.isEmpty {
//            return
//        }
//
//        dictPrefUpdate = dictPrefSelected
//        btn_back("")
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            NotificationCenter.default.post(name:NSNotification.Name (rawValue:"preference"), object: nil)
//        }
//    }
    
    @IBAction func btn_personal_info(_ sender:UIButton) {
        for i in 0..<btn_personal_info.count {
            if i+1 == sender.tag {
                btn_personal_info[i].setTitleColor(UIColor .black, for: .normal)
                if sender.tag == 1 {
                    is_interests = false
                } else {
                    is_interests = true
                    if getInterest.count == 0 {
                        func_get_interest()
                    }
                }
            } else {
                btn_personal_info[i].setTitleColor(UIColor .gray, for: .normal)
            }
        }
        tbl_preference.reloadData()
    }
    
}

extension PersonalInfoInterestVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if is_interests {
            return getInterest.count
        } else {
            return preference.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if is_interests {
            let dictInterestInfo = signUp!.interestInfo.dictionary
            let keyInterestInfo = getInterest[indexPath.row].interest
            
            if getInterest[indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNationlity", for: indexPath) as! PrefNationalityTVC
                
                cell.lbl_preference_name.text = getInterest[indexPath.row].interest
                cell.lblInfoValue.text = dictInterestInfo[keyInterestInfo] as? String
                
                cell.btnSelect.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
                
                cell.txtNationality.delegate = self
                cell.txtNationality.tag = indexPath.row
                cell.txtNationality.addTarget(self, action:#selector(txtSearch(_:)), for:.editingChanged)
                
//                if preference[indexPath.row].preference.lowercased() == "distance" {
//                    cell.txtNationality.keyboardType = .numberPad
//                } else {
                    cell.txtNationality.keyboardType = .default
//                }
                
                cell.lbl_preference_name.numberOfLines = 0
                cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                
                if arrSelect[indexPath.row] {
                    cell.heightNatioality.constant = 70
                    cell.viewNatioality.isHidden = false
                } else {
                    cell.heightNatioality.constant = 0
                    cell.viewNatioality.isHidden = true
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonalInfoPref_TableViewCell
                
                cell.lbl_preference_name.text = getInterest[indexPath.row].interest
                cell.lblInfoValue.text = dictInterestInfo[keyInterestInfo] as? String
                
                cell.btnSelect.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
                
                cell.selectedBoolArr = selectedCheckboxArr[indexPath.row]
                cell.valueInterest = getInterest[indexPath.row].value
                cell.collPref.tag = indexPath.row
                
                cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                cell.collPref.reloadData()
                
                if arrSelect[indexPath.row] {
                    cell.heightCollPref.constant = cell.collPref.collectionViewLayout.collectionViewContentSize.height
                    cell.collPref.isHidden = false
                    cell.topCollPref.constant = 10
                } else {
                    cell.heightCollPref.constant = 0
                    cell.collPref.isHidden = true
                    cell.topCollPref.constant = 0
                }
                return cell
            }
        } else {
            let dictPersonalInfo = signUp!.personalInfo.dictionary
            let keyPersonalInfo = preference[indexPath.row].preference.replacingOccurrences(of:" ", with:"_")
            
            if preference[indexPath.row].inputType == "text" || preference[indexPath.row].preference.lowercased() == "distance" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellNationlity", for: indexPath) as! PrefNationalityTVC
                
                cell.lbl_preference_name.text = preference[indexPath.row].preference.lowercased() == "distance" ? "Location" : preference[indexPath.row].preference
                cell.lblInfoValue.text = dictPersonalInfo[keyPersonalInfo] as? String
                
                cell.btnSelect.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
                
                cell.txtNationality.delegate = self
                cell.txtNationality.tag = indexPath.row
                cell.txtNationality.addTarget(self, action:#selector(txtSearch(_:)), for:.editingChanged)
                
                if preference[indexPath.row].preference.lowercased() == "distance" {
                    cell.txtNationality.keyboardType = .numberPad
                } else {
                    cell.txtNationality.keyboardType = .default
                }
                
                cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                
                if arrSelect[indexPath.row] {
                    cell.heightNatioality.constant = 70
                    cell.viewNatioality.isHidden = false
                } else {
                    cell.heightNatioality.constant = 0
                    cell.viewNatioality.isHidden = true
                }
                
                return cell
            } else if preference[indexPath.row].inputType == "range" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPrefRange", for: indexPath) as! PersonalInfoAgeTVC
                
                cell.lbl_preference_name.text = preference[indexPath.row].preference
                cell.lblInfoValue.text = dictPersonalInfo[keyPersonalInfo] as? String
                
                cell.btnSelect.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
                
                cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                
                if arrSelect[indexPath.row] {
                    cell.heightRange.constant = 50
                    cell.topRange.constant = 10
                    cell.viewRangeContainer.isHidden = false
                } else {
                    cell.heightRange.constant = 0
                    cell.topRange.constant = 0
                    cell.viewRangeContainer.isHidden = true
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonalInfoPref_TableViewCell
                
                cell.lbl_preference_name.text = preference[indexPath.row].preference
                cell.lblInfoValue.text = dictPersonalInfo[keyPersonalInfo] as? String
                
                cell.btnSelect.tag = indexPath.row
                cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
                
                cell.selectedBoolArr = selectedCheckboxArr[indexPath.row]
                cell.titlesArr = preference[indexPath.row].values
                cell.collPref.tag = indexPath.row
                
                cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                cell.collPref.reloadData()
                
                if arrSelect[indexPath.row] {
                    cell.heightCollPref.constant = cell.collPref.collectionViewLayout.collectionViewContentSize.height
                    cell.collPref.isHidden = false
                    cell.topCollPref.constant = 10
                } else {
                    cell.heightCollPref.constant = 0
                    cell.collPref.isHidden = true
                    cell.topCollPref.constant = 0
                }
                
                return cell
            }
        }
        
    }
    
    func funcMultipleSlider(_ multiSlider:MultiSlider) {
        multiSlider.valueLabelPosition = .top
        multiSlider.orientation = .horizontal
        multiSlider.thumbCount = 2
        multiSlider.thumbImage = UIImage (named:"thumb.png")
        multiSlider.tintColor = hexStringToUIColor("63EDAE")
        multiSlider.outerTrackColor = .gray
        multiSlider.keepsDistanceBetweenThumbs = true
        multiSlider.trackWidth = 4
        multiSlider.showsThumbImageShadow = false
        
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
                
        multiSlider.minimumValue = minValueSetDistance
        multiSlider.maximumValue = maxValueSetDistance
        
        multiSlider.value = [minValueSetDistance,maxValueSetDistance]
    }
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        dictPrefUpdate[preference[slider.tag].preference] = "\(Int64(minValueSetAge)),\(Int64(maxValueSetAge))"
    }
    
    @IBAction func btnSelect(_ sender:UIButton) {
        if user_idFriend != signUp?.userID {
            return
        }
        
        for i in 0..<arrSelect.count {
            if i == sender.tag {
                if arrSelect[i] {
                    arrSelect[i] = false
                } else {
                    arrSelect[i] = true
                }
            } else {
                arrSelect[i] = false
            }
        }
        
        tbl_preference.reloadData()
    }
    
}



import DropDown
import DatePickerDialog

//implementing extension from CLLocationManagerDelegate
extension PersonalInfoInterestVC {
    func funcDropNationality(_ textField:UITextField,countries: [String]) {
        dropNationality.dismissMode = .manual
        dropNationality.anchorView = textField
        dropNationality.bottomOffset = CGPoint(x: 0, y:textField.bounds.height)
        dropNationality.dataSource = countries
        
        dropNationality.selectionAction = { [weak self] (index, item) in
            textField.text = item
            self!.isValidNationality = true
            self?.view.endEditing(true)
        }
        dropNationality.show()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if is_interests {
            arrInterestInfoValue[textField.tag] = textField.text!
            funcUpdate_user_profile()
        } else {
            if preference[textField.tag].preference.lowercased() == "distance" {
                
            } else {
                if isValidNationality {
                   dictPrefUpdate["Nationality"] = textField.text!
                } else {
                    textField.text = ""
                    if let _ = dictPrefUpdate["Nationality"] {
                        dictPrefUpdate.removeValue(forKey:"Nationality")
                    }
                }
            }
            
            arrPersonalInfoValue[textField.tag] = textField.text!
            funcUpdate_user_profile()
        }
        
    }
    
    @IBAction func txtSearch(_ sender: UITextField) {
        arrSearched = [String]()
            
        for i in 0..<arrForSearch.count {
            let model = arrForSearch[i]
            let target = model
            if ((target as NSString?)?.range(of:sender.text!, options: .caseInsensitive))?.location == NSNotFound
            { } else {
                arrSearched.append(model)
            }
        }
        
        isValidNationality = false
        if sender.text!.count > 2 {
            funcDropNationality(sender, countries:arrSearched)
        } else {
            dropNationality.hide()
        }
    }
    
    func funcUpdate_user_profile() {
        var dictPersonalInfoUpdate = [String:String]()
        
        for i in 0..<preference.count {
            let keyPersonalInfo = preference[i].preference.replacingOccurrences(of:" ", with:"_")
            dictPersonalInfoUpdate[keyPersonalInfo] = arrPersonalInfoValue[i]
        }
        print(dictPersonalInfoUpdate)
        
        var dictInterestInfoUpdate = [String:String]()
        
        for i in 0..<getInterest.count {
            let keyPersonalInfo = getInterest[i].interest.replacingOccurrences(of:" ", with:"_")
            dictInterestInfoUpdate[keyPersonalInfo] = arrInterestInfoValue[i]
        }
        print(dictInterestInfoUpdate)
        
        let param = [
                "about_me":"",
                "friend_like":"",
                "describe_me":"",
                "hobbies":"",
                "personal_info":dictPersonalInfoUpdate.json,
                "interest_info":dictInterestInfoUpdate.json,
                "user_id":signUp!.userID
        ]
        print(param)
        
        APIFunc.postAPI("update_user_profile", param) { (json,status,message)  in
            DispatchQueue.main.async {
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    if signUp!.saveSignUp(json) {
                        print("saved")
                    }
                case .fail:
                    break
                case .error_from_api:
                    break
                }
                
            }
        }
    }
    
}

//MARK:- get_interest
extension PersonalInfoInterestVC {
    func func_get_interest() {
        let hud = KRProgressHUD.showOn(self)
ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.getAPI("get_interest",[:]) { (json, status, message) in
            DispatchQueue.main.async {
ViewControllerUtils.shared.hideActivityIndicator()
                if status == success_resp {
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getInterest = try decoder.decode([GetInterest].self, from: jsonData)
                            
                            self.arrSelect.removeAll()
                            for _ in preference {
                                self.arrSelect.append(false)
                            }
                            
                            self.updateCheckInterest()
                            self.tbl_preference.reloadData()
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                hud.showError(withMessage: "\(error.localizedDescription)")
                            })
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        hud.showError(withMessage: message)
                    }
                }
            }
        }
    }
}
