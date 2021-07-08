//  PrefViewController.swift
//  SheDistrict
//  Created by appentus on 3/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import MultiSlider


var dictPreferecenes = [String:String]()


class PrefViewController: UIViewController {
    @IBOutlet weak var tbl_preference:UITableView!
    
    var arrSelect = [Bool]()
    var selectedCheckboxArr = [[Bool]]()
    var isValidNationality = false
    
    var arrSearched = [String]()
    var arrForSearch = [String]()
    
    let dropNationality = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var countries: [String] = []
        
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
              
        arrForSearch = countries
        
        preference.removeAll()
        tbl_preference.estimatedRowHeight = 90
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
    
    func updateCheckboxBool() {
        selectedCheckboxArr = [[Bool]]()
        
        for i in 0..<preference.count {
            if preference[i].inputType == "checkbox" || preference[i].inputType == "radio" {
                var localBoolArr = [Bool]()
                
                for _ in 0..<preference[i].values.count {
                    localBoolArr.append(false)
                }
                self.selectedCheckboxArr.append(localBoolArr)
            } else {
                self.selectedCheckboxArr.append([false])
            }
        }
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
    
    @IBAction func btnCheckMark(_ sender:UIButton) {
        var dictPrefSelected = [String:String]()
        
        for i in 0..<selectedCheckboxArr.count {
            let arrSelectedCheckBox = selectedCheckboxArr[i]
            let arrPrefValue = preference[i].values
            var strPrefValue = ""
            
            for j in 0..<arrSelectedCheckBox.count {
                if arrSelectedCheckBox[j] {
                    strPrefValue = strPrefValue.isEmpty ? arrPrefValue[j].valueName : "\(strPrefValue),\(arrPrefValue[j].valueName)"
                } else {
                    for (key,value) in dictPreferecenes {
                        if key == preference[i].preference {
                            strPrefValue = value
                        }
                    }
                }
            }
            
            if !strPrefValue.isEmpty {
                dictPrefSelected[preference[i].preference.replacingOccurrences(of:" ", with:"_")] = strPrefValue
            }
        }
        print(dictPrefSelected)
        
        if dictPrefSelected.isEmpty {
            return
        }
        
        dictPreferecenes = dictPrefSelected
        btn_back("")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            NotificationCenter.default.post(name:NSNotification.Name (rawValue:"preference"), object: nil)
        }
    }
    
}

extension PrefViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preference.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if preference[indexPath.row].inputType == "range" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPrefRange", for: indexPath) as! PrefRangeTVC
            
            cell.lbl_preference_name.text = preference[indexPath.row].preference
            cell.multiSlider.tag = indexPath.row
            
            let minValue = CGFloat(Int(preference[indexPath.row].values[0].valueName.replacingOccurrences(of:" ", with:""))!)
            let maxValue = CGFloat(Int(preference[indexPath.row].values[1].valueName.replacingOccurrences(of:" ", with:""))!)
            
            minValueSetDistance = minValue
            maxValueSetDistance = maxValue
                
            if preference[indexPath.row].unit?.isEmpty ?? true {
                cell.lblMinRange.text = preference[indexPath.row].values[0].valueName
                cell.lblMaxRange.text = preference[indexPath.row].values[1].valueName
            } else {
                cell.lblMinRange.text = preference[indexPath.row].values[0].valueName+" \(preference[indexPath.row].unit!)"
                cell.lblMaxRange.text = preference[indexPath.row].values[1].valueName+" \(preference[indexPath.row].unit!)"
            }
            
            funcMultipleSlider(cell.multiSlider)
            
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
            
            if arrSelect[indexPath.row] {
                cell.heightRange.constant = 84
                cell.topRange.constant = 40
                cell.viewRangeContainer.isHidden = false
            } else {
                cell.heightRange.constant = 0
                cell.topRange.constant = 20
                cell.viewRangeContainer.isHidden = true
            }
            
            return cell
        } else if preference[indexPath.row].inputType == "text" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrefNationalityTVC", for: indexPath) as! PrefNationalityTVC
            
            cell.lbl_preference_name.text = preference[indexPath.row].preference
            
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
            
            cell.txtNationality.delegate = self
            cell.txtNationality.addTarget(self, action:#selector(txtSearch(_:)), for:.editingChanged)
            
            if arrSelect[indexPath.row] {
                cell.heightNationLITY.constant = 70
//                cell.viewNatioality.alpha = 1.0
            } else {
                cell.heightNationLITY.constant = 0.0
//                cell.viewNatioality.alpha = 0.0
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Preferences_TableViewCell
            
            cell.lbl_preference_name.text = preference[indexPath.row].preference
            
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(btnSelect(_:)), for: .touchUpInside)
            
            cell.btnUpDown.isSelected = arrSelect[indexPath.row]
                        
            cell.selectedBoolArr = selectedCheckboxArr[indexPath.row]
            cell.titlesArr = preference[indexPath.row].values
            cell.collPref.tag = indexPath.row
            
            if arrSelect[indexPath.row] {
                cell.frame = tableView.bounds
                cell.layoutIfNeeded()
                cell.collPref.reloadData()
                cell.heightCollPref.constant = cell.collPref.collectionViewLayout.collectionViewContentSize.height+20
                cell.collPref.isHidden = false
            } else {
                cell.heightCollPref.constant = 10
                cell.collPref.isHidden = true
            }
            
            return cell
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
        dictPreferecenes[preference[slider.tag].preference] = "\(Int64(minValueSetAge)),\(Int64(maxValueSetAge))"
        
//        if sliderType.lowercased() == "age" {
//            minValueSetAge = slider.value[0]
//            maxValueSetAge = slider.value[1]
//            dictPreferecenes["Age"] = "\(Int64(minValueSetAge)),\(Int64(maxValueSetAge))"
//        } else if sliderType.lowercased() == "distance" {
//            minValueSetDistance = slider.value[0]
//            maxValueSetDistance = slider.value[1]
//            dictPreferecenes["Distance"] = "\(Int64(minValueSetDistance)),\(Int64(maxValueSetDistance))"
//        }
        
    }
    
    @IBAction func btnSelect(_ sender:UIButton) {
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
//implementing extension from CLLocationManagerDelegate
extension PrefViewController {
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
        if isValidNationality {
           dictPreferecenes["Nationality"] = textField.text!
        } else {
            textField.text = ""
            if let _ = dictPreferecenes["Nationality"] {
                dictPreferecenes.removeValue(forKey:"Nationality")
            }
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
    
}


