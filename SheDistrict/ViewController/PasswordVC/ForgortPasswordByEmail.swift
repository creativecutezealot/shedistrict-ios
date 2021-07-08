//  ForgorPasswordByEmail.swift
//  SheDistrict
//  Created by iOS-Appentus on 30/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class ForgortPasswordByEmail: UIViewController {
    @IBOutlet weak var txtYourEmailAddress:UITextField!
    @IBOutlet weak var imgIcon:UIImageView!
    @IBOutlet weak var btnSubmit:UIButton!
    
    @IBOutlet weak var didntSaveLink:UIStackView!
    @IBOutlet weak var chooseDifferentType:UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        didntSaveLink.isHidden = true
        chooseDifferentType.isHidden = true
        btnSubmit.isHidden = false
    }
    
    @IBAction func btnSubmit(_ sender:UIButton) {
        self.view.endEditing(true)
        
        didntSaveLink.isHidden = false
        chooseDifferentType.isHidden = false
        btnSubmit.isHidden = true
        
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
        
        if txtYourEmailAddress.text!.isEmpty {
            isValid = false
        } else if !txtYourEmailAddress.text!.isValidEmail() {
            isValid = false
        } else {
            isValid = true
        }
        
        return isValid
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        imgIcon.image = UIImage (named:"Email.png")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        imgIcon.image = UIImage (named:"Email_g.png")
    }
    
}
