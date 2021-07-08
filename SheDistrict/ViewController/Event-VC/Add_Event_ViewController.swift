//  Add_Event_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/10/20.
//  Copyright © 2020 appentus. All rights reserved.


protocol Delegate_Add_Event {
    func func_rules_tips()
    func func_send_invitation(_ message:String)
    func func_rules_nevermind()
}


import UIKit
import DropDown
import KRProgressHUD
import CoreLocation
import DatePickerDialog


class Add_Event_ViewController: UIViewController,DelegateMeetWith {
    @IBOutlet weak var scroll_View:UIScrollView!
    
    @IBOutlet var text_field:[UITextField]!
    @IBOutlet var view_field:[UIView]!
    
    var hours = "00"
    var minute = "00"
    
    let am_pm_drown = DropDown()
    
//    var picker_Time = UIPickerView()
    
    var arr_min = [String]()
    var arr_hour = [String]()
    
    var delegate:Delegate_Add_Event?
        
    var arrSelectedFriend = [String]()
    
    var userIdsMeetWith = ""
    var monthPram = ""
    
    let datePicker = DatePickerDialog(
        textColor: .black,
        buttonColor: .black,
        font: UIFont (name:"Roboto-Regular", size:16)!,
        showCancelButton: true
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        funcSetUI()
    }
    
    func funcSetUI() {
//        for i in 1...12 {
//            self.arr_hour.append("\(i)")
//        }
//
//        for i in 0..<60 {
//            self.arr_min.append("\(i)")
//        }
        
        scroll_View.layer.cornerRadius = 10
        scroll_View.clipsToBounds = true
        
        for i in 0..<text_field.count {
            text_field[i].tag = i
            text_field[i].delegate = self
        }
        
//        picker_Time.delegate = self
//        picker_Time.dataSource = self
//
//        text_field[6].inputView = picker_Time
//        picker_Time.selectedRow(inComponent: 0)
        
        func_am_pm_drop_down()
    }
    
    @IBAction func btnMeetWith(_ sender:UIButton) {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let meetWithVC = storyboard.instantiateViewController(withIdentifier: "MeetWtihViewController") as! MeetWtihViewController
        meetWithVC.delegate = self
        self.addChild(meetWithVC)
        
        meetWithVC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(meetWithVC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            meetWithVC.view.transform = .identity
        })
    }
    
    func funcDoneDelegateMeetWith(_ userNames:String, _ userIDs:String) {
        text_field[0].text = userNames
        userIdsMeetWith = userIDs
    }
    
    @IBAction func btn_cancel(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
    @IBAction func btn_send_invitation(_ sender:UIButton) {
        if !funcValidation() {
            return
        }
//        func_removeFromSuperview()
//        delegate?.func_send_invitation()
        func_schedule_meeting()
    }
    
    @IBAction func btn_nevermind(_ sender:UIButton) {
        func_removeFromSuperview()
        delegate?.func_rules_nevermind()
    }
    
    @IBAction func btn_rules_tips(_ sender:UIButton) {
//        func_removeFromSuperview()
        delegate?.func_rules_tips()
    }
            
    private func funcValidation() -> Bool {
        var is_valid = false
        for i in 0..<text_field.count {
            if text_field[i].text!.isEmpty {
                view_field[i].shake()
                view_field[i].funcErrorShadowScheduleMetting()
                
                is_valid = false
                break
            } else {
                view_field[i].funcRemoveShadowScheduleMetting()
                is_valid = true
            }
        }
        
        return is_valid
    }
        
    func func_schedule_meeting() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let meeting_time = "\(text_field[6].text!) \(text_field[7].text!)"
        var meeting_date = "\(text_field[5].text!)/\(text_field[4].text!)/\(text_field[3].text!)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let meetingDate = formatter.date(from:meeting_date)
        meeting_date = formatter.string(from: meetingDate!)
        
        let param = [
                        "meeting_user_id":signUp!.userID,
                        "meeting_friend_id":userIdsMeetWith,
                        "meeting_subject":text_field[1].text!,
                        "meeting_reason":text_field[2].text!,
                        "meeting_date":meeting_date,
                        "meeting_time":meeting_time,
                        "meeting_location":text_field[8].text!
                    ]
        print(param)
        
        APIFunc.postAPI("schedule_meeting",param) { (json,status,message)  in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    self.func_removeFromSuperview()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                        self.delegate?.func_send_invitation(message)
                    })
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

extension Add_Event_ViewController:UITextFieldDelegate ,UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0{
            return arr_hour.count
        }else if component == 1{
            return 1
        }else if component == 2{
            return arr_min.count
        }else{
            return 1
        }
       
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return arr_hour[row]
        }else if component == 1{
            return "Hour"
        }else if component == 2{
            return arr_min[row]
        }else {
            return "Minute"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if row < 10 {
                hours = "0\(arr_hour[row])"
            } else {
                hours = "\(arr_hour[row])"
            }
        } else if component == 2{
            if row < 9 {
                minute = "0\(arr_min[row])"
            } else {
                minute = "\(arr_min[row])"
            }
        }
        text_field[6].text = "\(hours):\(minute)"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0{
            return 50
        } else if component == 1{
            return 80
        } else if component == 2{
            return 50
        } else{
            return 80
        }
    }
    
    func func_am_pm_drop_down() {
        let arr_year = ["AM","PM"]
        
        am_pm_drown.dismissMode = .manual
        am_pm_drown.anchorView = text_field[7]
        am_pm_drown.bottomOffset = CGPoint(x: 0, y:text_field[7].bounds.height)
        am_pm_drown.dataSource = arr_year
        
        am_pm_drown.selectionAction = { [weak self] (index, item) in
            self?.text_field[7].text = item
        }
    }
         
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        for view in view_field {
            view.funcRemoveShadowScheduleMetting()
        }
        
        if textField.tag == 0 {
            funcMeetWithSelection(textField)
            return false
        } else if 3 == textField.tag {
            datePickerTapped()
            return false
        } else if 4 == textField.tag {
            datePickerTapped()
            return false
        } else if 5 == textField.tag {
            datePickerTapped()
            return false
        } else if 6 == textField.tag {
            timePickerTapped()
            return false
        } else if 7 == textField.tag {
//            am_pm_drown.show()
            timePickerTapped()
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for i in 0..<text_field.count {
            if i+1 == textField.tag {
                if text_field[i].text!.isEmpty {
                    
                } else {
                    
                }
            }
        }
    }
    
    func funcMeetWithSelection(_ text:UITextField) {
        if !text.text!.isEmpty {
            let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
            let meetWithVC = storyboard.instantiateViewController(withIdentifier: "MeetWtihViewController") as! MeetWtihViewController
            meetWithVC.delegate = self
            
            let arrSelectMeetWith = text.text!.components(separatedBy: ",")
            meetWithVC.arrSelectMeetWith = arrSelectMeetWith
            
            self.addChild(meetWithVC)
            
            meetWithVC.view.transform = CGAffineTransform(scaleX:2, y:2)
            
            self.view.addSubview(meetWithVC.view)
            UIView.animate(withDuration:0.1, delay: 0, usingSpringWithDamping:0.3, initialSpringVelocity: 0, options: [],  animations: {
                meetWithVC.view.transform = .identity
            })
        }
    }
    
}

extension Add_Event_ViewController  {
    func timePickerTapped() {
        let minimumDate = Calendar.current.date(byAdding:.year, value:0, to: Date())
        let maximumDate = Calendar.current.date(byAdding:.year, value:5, to: Date())
        
        datePicker.show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minimumDate, maximumDate:maximumDate,datePickerMode:.time) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm a"
                let arrSelectedDate = formatter.string(from: dt).components(separatedBy:" ")
                self.text_field[6].text = arrSelectedDate[0]
                self.text_field[7].text = arrSelectedDate[1]
            }
        }
    }
    
    func datePickerTapped() {
        let minimumDate = Calendar.current.date(byAdding:.year, value:0, to: Date())
        let maximumDate = Calendar.current.date(byAdding:.year, value:5, to: Date())
        
        datePicker.show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minimumDate, maximumDate:maximumDate,datePickerMode: .date) { (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MMMM-yyyy"
                let arrSelectedDate = formatter.string(from: dt).components(separatedBy:"-")
                self.text_field[3].text = arrSelectedDate[0]
                self.text_field[4].text = arrSelectedDate[1]
                self.text_field[5].text = arrSelectedDate[2]
            }
        }
    }
    
}
