//  PrefRangeTVC.swift
//  SheDistrict
//  Created by appentus on 3/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import MultiSlider

var minValueSetAge = CGFloat(16)
var maxValueSetAge = CGFloat(80)

var minValueSetDistance = CGFloat(10)
var maxValueSetDistance = CGFloat(250)

var sliderType = ""

class PrefRangeTVC: UITableViewCell {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var lbl_preference_name:UILabel!
    @IBOutlet weak var btnSelect:UIButton!
    @IBOutlet weak var btnUpDown:UIButton!
    
    @IBOutlet weak var viewRangeContainer:UIView!
    @IBOutlet weak var multiSlider:MultiSlider!
    @IBOutlet weak var heightRange:NSLayoutConstraint!
    @IBOutlet weak var topRange:NSLayoutConstraint!
    
    @IBOutlet weak var lblMinRange:UILabel!
    @IBOutlet weak var lblMaxRange:UILabel!
    
    @IBOutlet weak var lblInfoValue:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    
}



