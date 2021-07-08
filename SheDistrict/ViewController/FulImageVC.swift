//
//  FulImageVC.swift
//  SheDistrict
//
//  Created by appentus on 2/28/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit
import SDWebImage


class FulImageVC: UIViewController {
    @IBOutlet weak var imgFullImage:UIImageView!
    var imgURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            self.imgURL.saveImageIn
        }
        imgFullImage.sd_setImage(with: URL(string:imgURL), placeholderImage:kDefaultLogo)
    }
    
    
    
}
