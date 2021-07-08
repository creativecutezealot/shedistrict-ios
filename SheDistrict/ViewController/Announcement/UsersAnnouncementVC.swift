//  UsersAnnouncementVC.swift
//  SheDistrict

//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit

class UsersAnnouncementVC: UIViewController {
    @IBOutlet weak var tblAnnouncement:UITableView!
    @IBOutlet weak var lblUserHasntPostedAnyAnnounement:UILabel!
    @IBOutlet weak var viewContainer:UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}



extension UsersAnnouncementVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UsersAnnouncementTVC
        
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action:#selector(btnSelect(_:)), for:.touchUpInside)
        
        if indexPath.row%2 == 0 {
            cell.viewContainer.funcSetShadow("D4F3EB")
        } else {
            cell.viewContainer.funcSetShadow("E6DEF3")
        }
        
        return cell
    }
    
    @IBAction func btnSelect(_ sender:UIButton) {
        func_Next_VC_Main_1("UsersAnnouncementDetails")
    }
    
}



extension UIView {
    func funcSetShadow(_ color:String) {
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = hexStringToUIColor(color).cgColor
    }
    
}
