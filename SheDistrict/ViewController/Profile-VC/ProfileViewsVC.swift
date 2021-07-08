//
//  ProfileViewsVC.swift
//  SheDistrict
//
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit
import KRProgressHUD

class ProfileViewsVC: UIViewController {
    
    @IBOutlet weak var collPreferenceUsers:UICollectionView!
    
    var viewrsModel : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getProfileViews()
    }
    
}



extension ProfileViewsVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32)/5
        return CGSize (width:width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewrsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"UserProfileViewsCollectionViewCell", for: indexPath) as! UserProfileViewsCollectionViewCell
        let current = viewrsModel[indexPath.row]
        let isBosted = "\(current["is_boosts"]!)"
        
        cell.isBoosted(isBosted=="0" ? false : true)
        cell.img_user.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: k_Base_URL_Imgae+(current["user_profile"] as! String))), placeholderImage:k_default_user)
        cell.btnSelectCollCell.tag = indexPath.row
        cell.btnSelectCollCell.addTarget(self, action:#selector(btnSelectCollCell(_:)), for: .touchUpInside)
        return cell
    }
    
    
    @objc func btnSelectCollCell(_ sender:UIButton) {
        
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = viewrsModel[sender.tag]["user_id"] as! String
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
    }
    
    @objc func btn_preferences(_ sender:UIButton) {
        //        func_Next_VC_Preference("PrefViewController")
    }
    
    func getProfileViews(){
        viewrsModel.removeAll()
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("get_viewers", ["user_id":signUp!.userID]) { (json, status, message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()
                
                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let resultArr = json[result_resp].array
                    for i in 0..<resultArr!.count{
                        let dict = resultArr![i].dictionaryObject!
                        self.viewrsModel.append(dict as NSDictionary)
                    }
                    self.collPreferenceUsers.reloadData()
                case .fail:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage: "\(json["message"])")
                    })
                case .error_from_api:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage:"error_message")
                    })
                }
            }
        }
    }
}

