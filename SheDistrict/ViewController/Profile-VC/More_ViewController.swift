//  Home_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import SDWebImage
import KRProgressHUD


class More_ViewController: UIViewController {
    @IBOutlet weak var imgUserProfile:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblTotalLikes:UILabel!
    @IBOutlet weak var collUserPhoto:UICollectionView!
    
    @IBOutlet weak var tblMore:UITableView!
    @IBOutlet weak var viewContainerProfile:UIView!
    @IBOutlet weak var lblBio:UILabel!
    @IBOutlet weak var heightBio:NSLayoutConstraint!
    
    @IBOutlet weak var topBio:NSLayoutConstraint!
    @IBOutlet weak var topUserPhotos:NSLayoutConstraint!
    @IBOutlet weak var heightUserPhotos:NSLayoutConstraint!
    
    let arr_border_color = ["ffd200","60edac","6071ed","ed60a9","4d245b","ffd200","60edac","6071ed","ed60a9","4d245b"]
    let arr_profile_icon = ["Settings.png","Scan.png","Question.png","logout.png"]
    let arr_profile_title = ["Settings","Scan","Help / FAQ","Log Out"]
    
    var delete_Sure_VC = Delete_Sure_VC()
    
    var timer:Timer!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        func_API_get_user_profile()
//        timer.fire()
        timer = Timer .scheduledTimer(timeInterval:5, target:self, selector:#selector(func_API_get_user_profile), userInfo:nil, repeats:true)
        funcUpdateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func funcUpdateUI() {
        imgUserProfile.sd_setImage(with: URL(string:(signUp?.userProfile.userProfile)!), placeholderImage:k_default_user)
        lblUserName.text = signUp?.userName
        lblBio.text = signUp?.userDetails[0].userBio
        lblTotalLikes.text = signUp?.userLike
        
        var viewContainerProfileEdit = viewContainerProfile.frame
        var fullHeightProfileContainer = CGFloat(126)
        
        if signUp?.userPhotos.count == 0 {
            topUserPhotos.constant = 0
            heightUserPhotos.constant = 0
        } else {
            topUserPhotos.constant = 20
            heightUserPhotos.constant = 80
        }
         
        if (signUp?.userDetails[0].userBio.isEmpty)! {
            topBio.constant = 0
            heightBio.constant = 0
        } else {
            topBio.constant = 16
            heightBio.constant = (signUp?.userDetails[0].userBio.height_According_Text(self.view.bounds.width-40,UIFont (name: "Roboto-Light", size: 16.0)!))!
        }
        
        fullHeightProfileContainer = fullHeightProfileContainer+heightBio.constant+heightUserPhotos.constant+topUserPhotos.constant
        viewContainerProfileEdit.size.height = fullHeightProfileContainer
        viewContainerProfile.frame = viewContainerProfileEdit
        tblMore.reloadData()
        
        collUserPhoto.reloadData()
        
        if delete_Sure_VC != nil {
            delete_Sure_VC.view.removeFromSuperview()
        }
    }
     
    @objc func func_API_get_user_profile() {
        let hud = KRProgressHUD.showOn(self)
        let param = ["user_id":"\(signUp!.userID)",
                    "friend_id":"\(signUp!.userID)"]
        
        APIFunc.postAPI("get_user_profile", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    signUp!.saveSignUp(json)
                case .fail:
                    print("\(json["message"])")
                case .error_from_api:
                    print("error_message")
                }
                self.lblTotalLikes.text = signUp?.userLike
            }
        }
    }
    
    @IBAction func btn_view_profile(_ sender:UIButton) {
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = signUp!.userID
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
    }
    
    @IBAction func btn_edit_profile(_ sender:UIButton) {
        func_Next_VC_Main_2("Edit_Profile_ViewController")
    }
    
    @IBAction func btn_select(_ sender:UIButton) {
        if sender.tag == 0 {
            func_Next_VC_Main_2("Settings_ViewController")
        } else if sender.tag == 1 {
            NotificationCenter.default.post(name: NSNotification.Name (rawValue:"show_QR_Code"), object: nil)
        } else if sender.tag == 2 {
            func_Next_VC_Main_3("Help_FAQ_ViewController")
        } else if sender.tag == arr_profile_title.count-1 {
            func_delete()
        }
    }
    
}



extension More_ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_profile_title.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Profile_TableViewCell
        
        cell.img_profile_icon.image = UIImage (named: arr_profile_icon[indexPath.row])
        cell.lbl_profile_title.text = arr_profile_title[indexPath.row]
        cell.btn_select.tag = indexPath.row
        cell.btn_select.addTarget(self, action: #selector(btn_select(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration:0.25, delay:0.01, animations: {
            cell.alpha = 1
        })
    }
    
}



extension More_ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:80, height:80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (signUp?.userPhotos.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Search_CollectionCell
        
        cell.img_user.layer.borderColor = hexStringToUIColor(arr_border_color[indexPath.row]) .cgColor
        cell.img_user.layer.borderWidth = 2
        
        let userPhotos = k_Base_URL_Imgae+(signUp?.userPhotos[indexPath.row].userPhotos)!
        cell.img_user.sd_setImage(with: URL(string:userPhotos), placeholderImage:k_default_user)
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        funcShowFullPicture((signUp?.userPhotos[indexPath.row].userPhotos.userProfile)!,3,(signUp?.userPhotos[indexPath.row])!)
    }
        
}



extension More_ViewController:Delegate_Delete_Sure,DelegateFullPictureVC {
    func func_delete() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Delete_Sure_VC") as! Delete_Sure_VC
        delete_Sure_VC.delegate = self
        delete_Sure_VC.str_up = "You're trying to log out..."
        delete_Sure_VC.str_down = "Are you sure?"
        
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            self.delete_Sure_VC.view.transform = .identity
        })
         
    }
    
    func func_Yes() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let param = ["user_id":signUp!.userID]
        APIFunc.postAPI("user_logout",param) { (json,status,message)  in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        UserDefaults.standard.removeObject(forKey:k_user_detals)
                        self.func_Next_VC("Login_Option_ViewController")
                    })
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
    
    func func_No() {
        
    }
        
    func funcShowFullPicture(_ imgUrl:String,_ buttonsShow:Int,_ selectedUserPhotos:UserPhoto) {
        let storyboard = UIStoryboard (name: "Preference", bundle: nil)
        let fullPictureVC = storyboard.instantiateViewController(withIdentifier: "FullPictureVC") as! FullPictureVC
        fullPictureVC.delegate = self
        fullPictureVC.buttonsShow = buttonsShow
        fullPictureVC.selectedUserPhotos = selectedUserPhotos
        fullPictureVC.imgUrl = imgUrl
        self.addChild(fullPictureVC)
        
        fullPictureVC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(fullPictureVC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            fullPictureVC.view.transform = .identity
        })
    }
    
    func funcReplace() {
        collUserPhoto.reloadData()
    }
    
}



