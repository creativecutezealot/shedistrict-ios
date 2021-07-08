//
//  MostCommonThings_VC.swift
//  SheDistrict
//
//  Created by appentus on 3/5/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit

class MostCommonThings_VC: UIViewController {
    
    @IBOutlet weak var lblSecond:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblSecond.attributedText =  boldWithRange("users with the most things in common.",
                      "most things in common.",
                      UIFont (name:"Roboto-Light", size:16),
                      UIFont (name:"Roboto-Regular", size:16))
    }
    
    @IBAction func btnOK(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
}
