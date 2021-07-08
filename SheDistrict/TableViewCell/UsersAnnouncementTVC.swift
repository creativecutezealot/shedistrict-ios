//  UsersAnnouncementTVC.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class UsersAnnouncementTVC: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var btnSelect:UIButton!
    @IBOutlet weak var viewContainer:UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
