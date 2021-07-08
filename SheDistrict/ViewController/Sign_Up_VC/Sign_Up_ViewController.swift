//  Sign_Up_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/3/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import DropDown
import UIView_Shake
import KRProgressHUD
import CoreLocation
import DatePickerDialog


class Sign_Up_ViewController: UIViewController {
    @IBOutlet var img_icon:[UIImageView]!
    @IBOutlet var tick_icon:[UIImageView]!
    @IBOutlet var view_field:[UIView]!
    @IBOutlet var text_field:[UITextField]!
    @IBOutlet var heightSelectQuestion:NSLayoutConstraint!
    @IBOutlet var bottomSelectQuestion:NSLayoutConstraint!
    @IBOutlet var collPref:UICollectionView!
    @IBOutlet var btnUpDown:UIButton!
    @IBOutlet var txtSelectedQuestion:UITextField!
    @IBOutlet var txtSecurityAnswer:UITextField!
    
    
    var questionID = ""
    var selectedBoolArr = [Bool]()
    
    let arr_img_icon_selected = ["Email.png","User.png","Lock.png","Phone.png"]
    let arr_img_icon_unselected = ["Email_g.png","User_g.png","Lock_g.png","Phone_g.png"]
     
    let date_picker_view = UIDatePicker()
    
    var co_OrdinateCurrent = CLLocationCoordinate2DMake(0.0, 0.0)
    var locationManager = CLLocationManager()
    
    let datePicker = DatePickerDialog(
        textColor: .black,
        buttonColor: .black,
        font: UIFont (name:"Roboto-Regular", size:16)!,
        showCancelButton: true
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func_core_location()
        
        heightSelectQuestion.constant = 0
        bottomSelectQuestion.constant = 0
                
        for i in 0..<text_field.count {
            text_field[i].tag = i+1
            text_field[i].delegate = self
        }
        
        funcGetSecurityQuestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arr_create_profile_fields = [Bool]()
        user_intro = nil
        user_bio_text = ""
        user_bio_image = nil
        user_bio_video = nil
    }
    
    private func func_validation() -> Bool {
        var is_valid = false
        for i in 0..<text_field.count {
            if text_field[i].text!.isEmpty {
                if i == 3 {
                    if text_field[3].text!.isEmpty {
                        is_valid = true
                        continue
                    }
                }
                
                view_field[i].shake()
                view_field[i].func_error_shadow()
                
                is_valid = false
                
                break
            } else {
                if !text_field[0].text!.isValidEmail() {
                    view_field[0].shake()
                    view_field[0].func_error_shadow()
                    
                    is_valid = false
                    break
                } else if text_field[2].text!.count < 6 && !text_field[2].text!.isEmpty {
                    view_field[2].shake()
                    view_field[2].func_error_shadow()
                    KRProgressHUD.showError(withMessage: "Password minimum length should be 6 digits.")
                    
                    is_valid = false
                    break
                } else if i == 3 {
                    if text_field[3].text!.count < 3 {
                        view_field[3].shake()
                        view_field[3].func_error_shadow()
                        KRProgressHUD.showError(withMessage: "Mobile number minimum length should be 3 digits.")
                        
                        is_valid = false
                        break
                    }
                }
                view_field[i].func_success_shadow()
                is_valid = true
            }
        }
        
        return is_valid
    }
    
    
    
    @IBAction func btnUpDown(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        btnUpDown.isSelected = sender.isSelected
        
        bottomSelectQuestion.constant = sender.isSelected ? CGFloat(20) : 0
        heightSelectQuestion.constant = sender.isSelected ? CGFloat((securityQuestion.count*34)+20) : 0
        
        UIView.animate(withDuration:0.3) {
            self.view.layoutIfNeeded()
        }
        
        for view in view_field {
            view.func_success_shadow()
        }
        
    }
    
    func funcGetSecurityQuestion() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.getAPI("get_security_question",[:]) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            securityQuestion = try decoder.decode([SecurityQuestionElement].self, from: jsonData)
                            for _ in 0..<securityQuestion.count {
                                self.selectedBoolArr.append(false)
                            }
                            
                            self.collPref.reloadData()
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                hud.showError(withMessage: "\(error.localizedDescription)")
                            })
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
    
    @IBAction func btn_next(_ sender:UIButton) {
        self.view.endEditing(true)
            
        if !func_validation() {
            return
        }
                
        var meeting_date = "\(text_field[6].text!)/\(text_field[4].text!)/\(text_field[5].text!)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let meetingDate = formatter.date(from:meeting_date)
        meeting_date = formatter.string(from: meetingDate!)
        
        let param = [
            "email":text_field[0].text!,
            "name":text_field[1].text!,
            "password":text_field[2].text!,
            "mobile":text_field[3].text!,
            "device_type":"2",
            "device_token":k_FireBaseFCMToken,
            "user_lat":"\(co_OrdinateCurrent.latitude)",
            "user_lang":"\(co_OrdinateCurrent.longitude)",
            "dob":meeting_date,
            "question":questionID,
            "answer":text_field.last!.text!
        ]
        print(param)
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("user_signup", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            signUp = try decoder.decode(SignUp.self, from: jsonData)
                            if (signUp?.userDetails[0].userBio.isEmpty)! && (signUp?.userDetails[0].userBioImage.isEmpty)! && (signUp?.userDetails[0].userBioVideo.isEmpty)! && (signUp?.userDetails[0].userIntroVideo.isEmpty)! {
                                self.func_Next_VC("Create_Your_Profile_VC")
                            } else {
                                self.func_Next_VC_Main_1("TabBar_SheDistrict")
                            }
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                hud.showError(withMessage: "\(error.localizedDescription)")
                            })
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
    
}



extension Sign_Up_ViewController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        for view in view_field {
            view.func_success_shadow()
        }
        
        if 5 == textField.tag {
            datePickerTapped()
            return false
        } else if 6 == textField.tag {
            datePickerTapped()
            return false
        } else if 7 == textField.tag {
            datePickerTapped()
            return false
        } else {
             return true
         }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for view in view_field {
            view.func_success_shadow()
        }
        
        for i in 0..<img_icon.count {
            if i+1 == textField.tag {
                if i+1 > 4 {
                    return
                }
                img_icon[i].image = UIImage (named:arr_img_icon_selected[textField.tag-1])
                tick_icon[i].image = UIImage (named: "Check.png")
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for i in 0..<text_field.count {
            if i+1 == textField.tag {
                if text_field[i].text!.isEmpty {
                    if i+1 > 4 {
                        return
                    }
                    
                    img_icon[i].image = UIImage (named:arr_img_icon_unselected[textField.tag-1])
                    tick_icon[i].image = UIImage (named: "Check_g.png")
                } else {
                    if i+1 > 4 {
                        return
                    }
                    
                    img_icon[i].image = UIImage (named:arr_img_icon_selected[textField.tag-1])
                    tick_icon[i].image = UIImage (named: "Check.png")
                    
                    if !text_field[0].text!.isValidEmail() {
                        img_icon[0].image = UIImage (named:arr_img_icon_unselected[textField.tag-1])
                        tick_icon[0].image = UIImage (named: "Check_g.png")
                    }
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if text_field[1] == textField {
            if string == " " {
               return false
            }
            return textFieldMaxLimit(textField, maxLimit:30,string)
       } else if text_field[2] == textField {
            return textFieldMaxLimit(textField, maxLimit:30,string)
       } else if text_field[3] == textField {
           return textFieldMaxLimit(textField, maxLimit:15,string)
       } else {
            return true
       }
    }
    
    func textFieldMaxLimit(_ textField:UITextField,maxLimit:Int64,_ string:String) -> Bool {
        if textField.text!.count < 40 {
            return true
        } else {
            if string == "" {
                return true
            } else {
                return false
            }
        }
    }
    
}

extension Sign_Up_ViewController:CLLocationManagerDelegate {
    func func_core_location() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        co_OrdinateCurrent = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension Sign_Up_ViewController  {
    func datePickerTapped() {
        let minimumDate = Calendar.current.date(byAdding:.year, value:-50, to: Date())
        let maximumDate = Calendar.current.date(byAdding:.year, value:-17, to: Date())
        
        datePicker.show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minimumDate, maximumDate:maximumDate,datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM-dd-yyyy"
                let arrSelectedDate = formatter.string(from: dt).components(separatedBy:"-")
                self.text_field[4].text = arrSelectedDate[0]
                self.text_field[5].text = arrSelectedDate[1]
                self.text_field[6].text = arrSelectedDate[2]
            }
        }
   }
    
}



extension Sign_Up_ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:collectionView.frame.width, height:34)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return securityQuestion.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! PrefCollectionViewCell
        
        cell.btnSelect.isSelected = selectedBoolArr[indexPath.row]
        cell.lblPreDetails.text = securityQuestion[indexPath.row].question
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<selectedBoolArr.count {
            if i == indexPath.row {
                selectedBoolArr[i] = true
            } else {
                selectedBoolArr[i] = false
            }
        }
        
        questionID = securityQuestion[indexPath.row].question
        txtSelectedQuestion.text = securityQuestion[indexPath.row].question
        self.collPref.reloadData()
    }
    
}


