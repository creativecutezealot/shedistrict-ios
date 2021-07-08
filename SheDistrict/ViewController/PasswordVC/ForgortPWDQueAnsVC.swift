//  QuestionAnswerVC.swift
//  SheDistrict
//  Created by iOS-Appentus on 30/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class ForgortPWDQueAnsVC: UIViewController {
    @IBOutlet weak var lblForgotYourPassword:UILabel!
    @IBOutlet weak var lblAnswerSecurityQustion:UILabel!
    
    @IBOutlet weak var txtQustion:UITextField!
    @IBOutlet weak var txtAnser:UITextField!
    
    @IBOutlet weak var viewSecurityAnswer:UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func btnCheckCancel(_ sender:UIButton) {
        
    }
    
    @IBAction func btnEmail(_ sender:UIButton) {
        func_Next_VC_Preference("ForgortPasswordByEmail")
    }
    
    @IBAction func btnSMS(_ sender:UIButton) {
        func_Next_VC_Preference("ForgortPWDByNumber")
    }
    
    @IBAction func btnVerifyByPhoto(_ sender:UIButton) {
        func_Next_VC("Verify_YourSelf_Camera_VC")
    }
    
}
