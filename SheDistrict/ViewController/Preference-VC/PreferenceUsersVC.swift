//  PreferenceUsersVC.swift
//  SheDistrict
//  Created by appentus on 3/5/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class PreferenceUsersVC: UIViewController {
    @IBOutlet weak var collPreferenceUsers:UICollectionView!
    @IBOutlet weak var lblPreference:UILabel!
    
    var prefSelectedUserAccordingPreference:[UserAccordingPreference] = []
    
    var userPreference = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPreference.text = userPreference.replacingOccurrences(of:"_", with:" ")
    }
    
}



extension PreferenceUsersVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collPreferenceUsers.bounds.width - 40)/5
        return CGSize (width:width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prefSelectedUserAccordingPreference.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Search_CollectionCell
        
        cell.view_container.layer.masksToBounds = false
        cell.view_container.layer.cornerRadius = cell.view_container.frame.height/2
        cell.view_container.layer.shadowColor = hexStringToUIColor("60EDAC").cgColor
        cell.view_container.layer.shadowPath = UIBezierPath(roundedRect:cell.view_container.bounds, cornerRadius:cell.view_container.layer.cornerRadius).cgPath
        cell.view_container.layer.shadowOffset = CGSize(width: 0.0, height: 3)
        cell.view_container.layer.shadowOpacity = 0.3
        cell.view_container.layer.shadowRadius = 3
        
        cell.img_user.layer.cornerRadius = cell.img_user.frame.height/2
        cell.img_user.clipsToBounds = true
        
        if prefSelectedUserAccordingPreference.count > indexPath.row {
            let userProfile = prefSelectedUserAccordingPreference[indexPath.row].userProfile.userProfile
            cell.img_user.sd_setImage(with: URL(string:userProfile), placeholderImage:k_default_user)
        } else {
            cell.img_user.image = k_default_user
        }
        
        cell.btnSelectCollCell.tag = indexPath.row
        cell.btnSelectCollCell.addTarget(self, action:#selector(btnSelectCollCell(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @IBAction func btnSelectCollCell(_ sender:UIButton) {
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = prefSelectedUserAccordingPreference[sender.tag].userID
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
    }
    
    @IBAction func btn_preferences(_ sender:UIButton) {
        func_Next_VC_Preference("PrefViewController")
    }
    
}

