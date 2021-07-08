//  PrefNationalityTVC.swift
//  SheDistrict
//  Created by appentus on 3/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit

class PrefNationalityTVC: UITableViewCell {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var lbl_preference_name:UILabel!
    @IBOutlet weak var txtNationality:UITextField!
    @IBOutlet weak var btnSelect:UIButton!
    @IBOutlet weak var btnUpDown:UIButton!
    
    @IBOutlet weak var heightNationLITY: NSLayoutConstraint!
    @IBOutlet weak var heightNatioality:NSLayoutConstraint!
    @IBOutlet weak var viewNatioality:UIView!
    
    @IBOutlet weak var lblInfoValue:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
