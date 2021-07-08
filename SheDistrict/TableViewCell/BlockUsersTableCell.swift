//
//  BlockUsersTableCell.swift
//  SheDistrict
//
//  Created by appentus on 2/25/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit

class BlockUsersTableCell: UITableViewCell {
    @IBOutlet weak var imgProfileUsers:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblBlockedOn:UILabel!
    @IBOutlet weak var btnUnBlock:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
