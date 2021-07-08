//  AnotherVerification_VC.swift
//  SheDistrict

//  Created by iOS-Appentus on 30/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class AnotherVerification_VC: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
      
    @IBAction func btnCancel(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
    @IBAction func btnEmail(_ sender:UIButton) {
        func_Next_VC_Preference("ForgortPasswordByEmail")
    }

    @IBAction func btnSMS(_ sender:UIButton) {
        func_Next_VC_Preference("ForgortPWDByNumber")
    }
    
    @IBAction func btnSecurityQuestion(_ sender:UIButton) {
        func_Next_VC_Preference("ForgortPWDQueAnsVC")
    }
    
}
