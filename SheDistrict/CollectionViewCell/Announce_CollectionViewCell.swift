//  Announce_CollectionViewCell.swift
//  SheDistrict
//  Created by appentus on 1/7/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit

var selectedColorAnnouncemenet = ""
var selectedCateID = ""

class Announce_CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img_user_profile:UIImageView!
    @IBOutlet weak var lbl_user_name:UILabel!
    @IBOutlet weak var lbl_time:UILabel!
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var img_annoucement:UIImageView!
    @IBOutlet weak var lbl_description:UILabel!
    @IBOutlet weak var btn_chat:UIButton!
    @IBOutlet weak var btnThreeDot:UIButton!
    @IBOutlet weak var imgThreeDot: UIImageView!

    @IBOutlet weak var viewContainer:UIView!
}



