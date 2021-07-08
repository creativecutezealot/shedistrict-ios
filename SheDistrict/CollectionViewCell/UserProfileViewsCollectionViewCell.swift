//
//  UserProfileViewsCollectionViewCell.swift
//  SheDistrict
//
//  Created by Ayush Pathak on 18/06/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit

class UserProfileViewsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var img_user:UIImageView!
    @IBOutlet weak var btnSelectCollCell:UIButton!
    @IBOutlet weak var viewAboveGrad: UIView!
    
    @IBOutlet weak var gradientBgView: UIView!
    
    
    override func layoutSubviews() {

    }
    
    func isBoosted(_ val : Bool) {
        self.layoutIfNeeded()

        if val{
            self.gradientBgView.setGradientBackground()

        }else{
            if let sublayers = self.gradientBgView.layer.sublayers{
                for i in 0..<sublayers.count{
                    if sublayers[i].isKind(of: CAGradientLayer.self){
                        self.gradientBgView.layer.sublayers?.remove(at: i)
                    }
                }
            }
        }
        

        self.gradientBgView.layer.cornerRadius = self.gradientBgView.frame.height/2
        self.gradientBgView.layer.masksToBounds = true
        self.viewAboveGrad.layer.cornerRadius = self.viewAboveGrad.frame.height/2
        self.viewAboveGrad.layer.masksToBounds = true

        self.view_container.layer.cornerRadius = self.view_container.frame.height/2
        self.view_container.layer.masksToBounds = true
        self.img_user.layer.cornerRadius = self.img_user.frame.height/2
        self.img_user.layer.masksToBounds = true
    }
}
