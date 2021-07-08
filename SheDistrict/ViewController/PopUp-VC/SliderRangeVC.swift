//  SliderRangeVC.swift
//  SheDistrict
//  Created by appentus on 2/28/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import MultiSlider

//var minValueSetAge = CGFloat(1)
//var maxValueSetAge = CGFloat(100)
//
//var minValueSetDistance = CGFloat(1)
//var maxValueSetDistance = CGFloat(100)


class SliderRangeVC: UIViewController {
    @IBOutlet weak var multiSlider:MultiSlider!
    @IBOutlet weak var lblTitle:UILabel!
    
    var sliderType = ""
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        funcMultipleSlider()
    }
    
    func funcMultipleSlider() {
        multiSlider.valueLabelPosition = .top
        multiSlider.orientation = .horizontal
        multiSlider.thumbCount = 2
        multiSlider.tintColor = hexStringToUIColor("63EDAE")
        multiSlider.outerTrackColor = .gray
        multiSlider.keepsDistanceBetweenThumbs = true
        multiSlider.trackWidth = 34
        multiSlider.showsThumbImageShadow = false
//        multiSlider.isValueLabelRelative = true
        
        multiSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        
        if sliderType.lowercased() == "age" {
            lblTitle.text = "In Years"
            multiSlider.minimumValue = 1
            multiSlider.maximumValue = 100
            
//            multiSlider.valueLabelFormatter.positiveSuffix = " Yrs"
            multiSlider.value = [minValueSetAge,maxValueSetAge]
        } else if sliderType.lowercased() == "distance" {
            lblTitle.text = "In Miles"
            
            multiSlider.minimumValue = 1
            multiSlider.maximumValue = 100
            
//            multiSlider.valueLabelFormatter.positiveSuffix = " Miles"
            multiSlider.value = [minValueSetDistance,maxValueSetDistance]
        }
    }
    
    
    
    @objc func sliderChanged(_ slider: MultiSlider) {
        if sliderType.lowercased() == "age" {
            minValueSetAge = slider.value[0]
            maxValueSetAge = slider.value[1]
            dictPreferecenes["Age"] = "\(Int64(minValueSetAge))-\(Int64(maxValueSetAge))"
        } else if sliderType.lowercased() == "distance" {
            minValueSetDistance = slider.value[0]
            maxValueSetDistance = slider.value[1]
            dictPreferecenes["Distance"] = "\(Int64(minValueSetDistance))-\(Int64(maxValueSetDistance))"
        }
        
    }
    
    @IBAction func btnCancel(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
}
