//  ForgotPWDByOTP.swift
//  SheDistrict
//  Created by iOS-Appentus on 30/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class ForgotPWDByOTP: UIViewController,UITextFieldDelegate {
    @IBOutlet var textFields:[UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<textFields.count{
            textFields[i].tag = i
            textFields[i].keyboardType = .phonePad
            textFields[i].delegate = self
            textFields[i].textAlignment = .center
            textFields[i].addTarget(self, action:#selector(textField(_:)), for:.editingChanged)
        }
    }
    
    @IBAction func btnSubmit(_ sender:UIButton) {
        self.view.endEditing(true)
        
        if !func_validation() {
            
        }
    }
    
    @IBAction func btnAnotherOptionVerify(_ sender:UIButton) {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let anotherVerificationVC = storyboard.instantiateViewController(withIdentifier: "AnotherVerification_VC") as! AnotherVerification_VC
        
        self.addChild(anotherVerificationVC)
        
        anotherVerificationVC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(anotherVerificationVC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            anotherVerificationVC.view.transform = .identity
        })
    }
    
    private func func_validation() -> Bool {
        var isValid = false
        
        for i in 0..<textFields.count {
            if textFields[i].text!.isEmpty {
                isValid = false
                break
            } else {
                isValid = true
            }
        }
        
        return isValid
    }
    
    @IBAction func textField(_ sender:UITextField) {
        if sender.text!.count > 0 {
            if sender.tag == textFields.count-1 {
                self.view.endEditing(true)
                return
            }
            textFields[sender.tag+1].becomeFirstResponder()
        } else {
            if sender.tag == 0 {
                return
            }
            if sender.text == "" {
                textFields[sender.tag-1].becomeFirstResponder()
            } else {
                textFields[sender.tag+1].becomeFirstResponder()
            }
        }
        
    }
    
    
    
    
}
