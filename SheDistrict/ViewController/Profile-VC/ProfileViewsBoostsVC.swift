//  ProfileViewsBoostsVC.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class ProfileViewsBoostsVC: UIViewController {
    @IBOutlet var btn_selected_announcements:[UIButton]!
    @IBOutlet weak var view_dot_selected:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_selected_announcements[0].setTitleColor(hexStringToUIColor("#593C67"), for: .normal)

        NotificationCenter.default.addObserver(self, selector: #selector(func_set_selected(noti:)),name:NSNotification.Name(rawValue:"selected_events"), object: nil)
    }
    
    @objc func func_set_selected(noti:Notification)  {
        let selected_tag = noti.object as! Int
        view_dot_selected.center.x = btn_selected_announcements[selected_tag].center.x
        
        for i in 0..<btn_selected_announcements.count {
            if i == selected_tag {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor("#593C67"), for: .normal)
            } else {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor("#E1E1E1"), for: .normal)
            }
        }
        
    }
    
    @IBAction func btn_selected_announcements(_ sender:UIButton) {
        let selected_tag = sender.tag
        view_dot_selected.center.x = btn_selected_announcements[selected_tag].center.x
        
        for i in 0..<btn_selected_announcements.count {
            if i == selected_tag {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor("#593C67"), for: .normal)
            } else {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor("#E1E1E1"), for: .normal)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"move_by_buttons_events"), object: sender.tag)
    }
    
    @IBAction func btn_add_event(_ sender:Any) {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"add_event"), object:nil)
    }
    
}

