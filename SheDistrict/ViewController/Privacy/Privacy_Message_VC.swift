//  Message_Privacy_VC.swift
//  SheDistrict
//  Created by appentus on 1/16/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD


class Privacy_Message_VC: UIViewController {
    var status = [String:Any]()
    var premium_status = [String:Any]()
    
    @IBOutlet var buttons:[UIButton]!
    @IBOutlet var switches:[UISwitch]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        funcUISet()
    }
    
    func funcUISet() {
        status = signUp!.allowMsg.dictionary
        premium_status = signUp!.premiumData.dictionary
                
        buttons[0].isSelected = "\(status["1"] ?? "0")" == "1" ? true : false
        buttons[1].isSelected = "\(status["2"] ?? "0")" == "1" ? true : false
        buttons[2].isSelected = "\(status["3"] ?? "0")" == "1" ? true : false
        
        switches[0].isOn = "\(premium_status["1"] ?? "0")" == "1" ? true : false
        switches[1].isOn = "\(premium_status["2"] ?? "0")" == "1" ? true : false
    }
            
    @IBAction func btn_tick(_ sender:UIButton) {
        for i in 0..<buttons.count {
            let buttonSelected = buttons[i]
            if buttonSelected.tag == sender.tag {
                buttons[i].isSelected = true
                status["\(i+1)"] = "1"
            } else {
                buttons[i].isSelected = false
                status["\(i+1)"] = "0"
            }
        }
        func_update_message_setting()
    }
    
   @IBAction func btnSwitch(_ sender:UISwitch) {
        if sender.tag == 0 {
            let isOn = sender.isOn ? "1" : "0"
            premium_status["1"] = isOn
        } else if sender.tag == 1 {
            let isOn = sender.isOn ? "1" : "0"
            premium_status["2"] = isOn
        }
        print(premium_status)
        func_update_message_setting()
    }
    
    func func_update_message_setting() {
        let param = [
            "status":status.json,
            "premium_status":premium_status.json,
            "user_id":signUp!.userID
        ]
        print(param)
        
        let hud = KRProgressHUD.showOn(self)
//        hud.show()
        APIFunc.postAPI("update_message_setting", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    if signUp!.saveSignUp(json) {
//                        self.funcUISet()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                            hud.showError(withMessage:"Something went wrong")
                        })
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
