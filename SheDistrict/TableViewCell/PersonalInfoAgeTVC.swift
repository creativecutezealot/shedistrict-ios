//
//  PersonalInfoAgeTVC.swift
//  SheDistrict
//
//  Created by appentus on 3/19/20.
//  Copyright © 2020 appentus. All rights reserved.
//




import UIKit
import DatePickerDialog


class PersonalInfoAgeTVC: UITableViewCell {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var lbl_preference_name:UILabel!
    @IBOutlet weak var btnSelect:UIButton!
    @IBOutlet weak var btnUpDown:UIButton!
    
    @IBOutlet weak var viewRangeContainer:UIView!
  
    @IBOutlet weak var heightRange:NSLayoutConstraint!
    @IBOutlet weak var topRange:NSLayoutConstraint!
        
    @IBOutlet weak var lblInfoValue:UILabel!
  
    @IBOutlet var text_field:[UITextField]!
    
    let datePicker = DatePickerDialog(
        textColor: .black,
        buttonColor: .black,
        font: UIFont (name:"Roboto-Regular", size:16)!,
        showCancelButton: true
    )
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            
    }
        
    @IBAction func btnAge(_ sender:UIButton) {
         let minimumDate = Calendar.current.date(byAdding:.year, value:-50, to: Date())
         let maximumDate = Calendar.current.date(byAdding:.year, value:-17, to: Date())
         
         datePicker.show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minimumDate, maximumDate:maximumDate,datePickerMode: .date) { (date) in
             if let dt = date {
                 let formatter = DateFormatter()
                 formatter.dateFormat = "MMMM-dd-yyyy"
                 let arrSelectedDate = formatter.string(from: dt).components(separatedBy:"-")
                 self.text_field[0].text = arrSelectedDate[0]
                 self.text_field[1].text = arrSelectedDate[1]
                 self.text_field[2].text = arrSelectedDate[2]
                
                formatter.dateFormat = "dd/MM/yyyy"
                arrPersonalInfoValue[0] = formatter.string(from: dt)
                self.funcUpdate_user_profile()
             }
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
