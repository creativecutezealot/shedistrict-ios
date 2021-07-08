//
//  customLoader.swift
//  SheDistrict
//
//  Created by Ayush Pathak on 16/06/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerUtils {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    let imgLoader = UIImageView()
    let window = UIApplication.shared.keyWindow
    
    static let shared = ViewControllerUtils()
    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
     
     @param uiView - add activity indicator to this view
     */
    func showActivityIndicator() {
        window?.isUserInteractionEnabled = false
        container.frame = window!.frame
        container.center = window!.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = window!.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        imgLoader.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        imgLoader.image = UIImage(named: "0.png")
        
        imgLoader.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        imgLoader.rotate()
        loadingView.addSubview(imgLoader)
        container.addSubview(loadingView)
        window!.addSubview(container)
    }
    
    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
     
     @param uiView - remove activity indicator from this view
     */
    func hideActivityIndicator() {
        window?.isUserInteractionEnabled = true
        imgLoader.stopRotating()
        container.removeFromSuperview()
    }
    
    /*
     Define UIColor from hex value
     
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    
}
extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)
//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)
