//  ResetPasswordVC.swift
//  SheDistrict
//  Created by iOS-Appentus on 27/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD


class ResetPasswordVC: UIViewController {
    @IBOutlet var viewField:[UIView]!
    @IBOutlet var textField:[UITextField]!
    @IBOutlet var btnEyePassword:[UIButton]!
    @IBOutlet weak var viewErrorContianer:UIView!
    @IBOutlet weak var lblErrorContianer:UILabel!
    @IBOutlet weak var topErrorContainer:NSLayoutConstraint!
    @IBOutlet weak var viewSuccess:UIView!
    @IBOutlet weak var lblSuccessMSG:UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSuccess.isHidden = true
        viewErrorContianer.isHidden = true
        
        for i in 0..<btnEyePassword.count {
            viewField[i].tag = i
            textField[i].isSecureTextEntry = true
            btnEyePassword[i].tag = i
            btnEyePassword[i].isSelected = false
            btnEyePassword[i].addTarget(self, action:#selector(btnViewPassword(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func btnReset(_ sender:UIButton) {
        self.view.endEditing(true)
        if !func_validation() {
            return
        }
        
    }
    
    @IBAction func btnCancelSuccess(_ sender:UIButton) {
        viewSuccess.isHidden = true
    }
    
    @IBAction func btnCancelError(_ sender:UIButton) {
        viewErrorContianer.isHidden = true
    }
    
    @IBAction func btnInfo(_ sender:UIButton) {
        
    }
    
    @IBAction func btnViewPassword(_ sender:UIButton) {
        if sender.tag == 0 {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            
            textField[sender.tag].isSecureTextEntry = !sender.isSelected
        } else {
            if sender.isSelected {
                sender.isSelected = false
            } else {
                sender.isSelected = true
            }
            
            textField[sender.tag].isSecureTextEntry = !sender.isSelected
        }
    }
    
    private func func_validation() -> Bool {
        var is_valid = false
        
        if textField[0].text!.isEmpty {
            is_valid = false
        } else if textField[0].text!.count < 6 {
            funcErrorShadow(viewField[0],"Password must contains at least 6 charcters")
            is_valid  =  false
        } else if textField[1].text!.isEmpty {
            is_valid  = false
        } else if textField[1].text!.count < 6 {
            funcErrorShadow(viewField[1],"Password must contains at least 6 charcters")
            is_valid =  false
        } else if textField[1].text! != textField[0].text! {
            funcErrorShadow(viewField[1],"New password and confirm new password must be same")
            is_valid  = false
        } else {
            is_valid  = true
        }
        return is_valid
    }
    
    func funcErrorShadow(_ view:UIView,_ msg:String) {
        viewErrorContianer.isHidden = false
        lblErrorContianer.text = msg
        if view.tag == 0 {
            topErrorContainer.constant = 40
        } else {
            topErrorContainer.constant = 115
        }
    }
    
    
}

