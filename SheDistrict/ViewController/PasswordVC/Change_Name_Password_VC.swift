//  Change_Name_Password_VC.swift
//  SheDistrict
//  Created by appentus on 1/16/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD


class Change_Name_Password_VC: UIViewController {
    @IBOutlet weak var txtCurrentUserName:UITextField!
    @IBOutlet weak var txtNewUserName:UITextField!
    
    @IBOutlet weak var txtOldPassword:UITextField!
    @IBOutlet weak var txtNewPassword:UITextField!
    
    var changeStatus = ""
    
    @IBOutlet var heightChange:[NSLayoutConstraint]!
    @IBOutlet var stackView:[UIStackView]!
    @IBOutlet var imgArrow:[UIImageView]!
    
    @IBOutlet weak var lblNote:UILabel!
    
    @IBOutlet var buttonChange:[UIButton]!
    
    var arrSelect = [Bool]()
        
    @IBOutlet weak var viewPassword:UIView!
    @IBOutlet weak var btnSubmit:UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.isUserInteractionEnabled = false
        lblNote.isHidden = true
        
        if !signUp!.userSocial.isEmpty {
            viewPassword.isHidden = true
        }
        
        for stack in stackView {
            stack.isHidden = true
        }
        
        for height in heightChange {
            height.constant = 50
            arrSelect.append(false)
        }
        
        for img in imgArrow {
            img.image = UIImage (named:"next-arrow.png")
        }
        
        for i in 0..<buttonChange.count {
            buttonChange[i].tag = i
            buttonChange[i].addTarget(self, action:#selector(buttonChange(_:)), for:.touchUpInside)
        }
        
    }
    
    @IBAction func buttonChange(_ sender:UIButton) {
        btnSubmit.isUserInteractionEnabled = true
                    
        for i in 0..<buttonChange.count {
            if i == sender.tag {
                if sender.tag == 0 {
                    if heightChange[0].constant == 220 {
                        stackView[0].isHidden = true
                        heightChange[0].constant = 50
                        imgArrow[0].image = UIImage (named:"next-arrow.png")
                        lblNote.isHidden = true
                        btnSubmit.isUserInteractionEnabled = false
                    } else {
                        changeStatus = "1"
                        stackView[0].isHidden = false
                        heightChange[0].constant = 220
                        lblNote.isHidden = false
                        imgArrow[0].image = UIImage (named:"down-arrow.png")
                    }
                } else {
                    if heightChange[1].constant == 180 {
                        stackView[1].isHidden = true
                        heightChange[1].constant = 50
                        imgArrow[1].image = UIImage (named:"next-arrow.png")
                        btnSubmit.isUserInteractionEnabled = false
                    } else {
                        changeStatus = "0"
                        stackView[1].isHidden = false
                        heightChange[1].constant = 180
                        lblNote.isHidden = true
                        imgArrow[1].image = UIImage (named:"down-arrow.png")
                    }
                }
//                imgArrow[i].image = UIImage (named:"next-arrow.png")
            } else {
                stackView[i].isHidden = true
                heightChange[i].constant = 50
                imgArrow[i].image = UIImage (named:"next-arrow.png")
            }
        }
        
        UIView.animate(withDuration:0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
        
    @IBAction func btnSubmit(_ sender:UIButton) {
        if changeStatus == "1" {
            func_API_update_user_name()
        } else if changeStatus == "0" {
            func_API_update_user_change_password()
        }
    }
    
    func func_API_update_user_name() {
        let hud = KRProgressHUD.showOn(self)
        
        if txtCurrentUserName.text!.isEmpty {
            hud.showError(withMessage: "Enter current user name")
            return
        } else if txtNewUserName.text!.isEmpty {
            hud.showError(withMessage: "Enter new user name")
            return
        } else {
            let hud = KRProgressHUD.showOn(self)
            ViewControllerUtils.shared.showActivityIndicator()

            let param = ["user_id":"\(signUp!.userID)",
                        "user_name_old":txtCurrentUserName.text!,
                        "user_name_new":txtNewUserName.text!
                        ]
             print(param)
             
             APIFunc.postAPI("update_user_name", param) { (json,status,message) in
                 DispatchQueue.main.async {
                     ViewControllerUtils.shared.hideActivityIndicator()

                     switch status {
                     case success_resp:
                         self.funcDeletedMessage(status,"",message)
                        signUp!.saveSignUp(json)
                     case failed_resp:
                         DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                             hud.showError(withMessage: "\(json["message"])")
                         })
                     default:
                         break
                     }
                 }
             }
        }
        
    }
    
    func func_API_update_user_change_password() {
            let hud = KRProgressHUD.showOn(self)
            
            if txtOldPassword.text!.isEmpty {
                hud.showError(withMessage:"Enter old password")
                return
            } else if txtOldPassword.text!.count < 6 {
                 hud.showError(withMessage: "Old password length must be greater 6")
                return
            } else if txtNewPassword.text!.isEmpty {
                hud.showError(withMessage: "Enter new password")
                return
            } else if txtNewPassword.text!.count < 6 {
                hud.showError(withMessage:"New password length must be greater 6")
                return
            } else {
                let hud = KRProgressHUD.showOn(self)
                ViewControllerUtils.shared.showActivityIndicator()

                let param = ["user_id":"\(signUp!.userID)",
                            "password_old":txtOldPassword.text!,
                            "password_new":txtNewPassword.text!
                            ]
                print(param)
                
             APIFunc.postAPI("update_password", param) { (json,status,message) in
                 DispatchQueue.main.async {
                     ViewControllerUtils.shared.hideActivityIndicator()

                     switch status {
                     case success_resp:
                         self.funcDeletedMessage(status,"",message)
                        signUp!.saveSignUp(json)
                     case failed_resp:
                         DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                             hud.showError(withMessage: "\(json["message"])")
                         })
                     default:
                         break
                     }
                 }
             }
        }
    }
    
}
