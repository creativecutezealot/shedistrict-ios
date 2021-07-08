//  MyProfileDetailsVC.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class MyProfileDetailsVC: UIViewController {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblAbout:UILabel!
    @IBOutlet weak var lblImLookingForFriends:UILabel!
    
    @IBOutlet weak var imgUserProfile:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblBio:UILabel!
    @IBOutlet weak var collUserPhoto:UICollectionView!
    @IBOutlet weak var topBio:NSLayoutConstraint!
    @IBOutlet weak var topUserPhotos:NSLayoutConstraint!
    @IBOutlet weak var heightUserPhotos:NSLayoutConstraint!
    @IBOutlet weak var lblAboutUser:UILabel!
    
    @IBOutlet var btnUserActions:[UIButton]!
        
    let arr_border_color = ["ffd200","60edac","6071ed","ed60a9","4d245b","ffd200","60edac","6071ed","ed60a9","4d245b","60edac","6071ed","ed60a9","4d245b"]
    let arr_profile_icon = ["Settings.png","Form.png","Scan.png","Question.png"]
    
    let arr_left_info = ["Age","Ethnicity","Nationality","Religion","Distance","Education","Relationship Status","Sexual Orientation","Has Kids?"]
    let arr_right_info = ["25","India","India","Hindu","Distance","Uni","Single","Sexual Orientation","No"]
    
    let arr_left_interests = ["Favorite Food","Favorite Color","Favorite Music Genre","Favorite Movie Genre","Favorite Type of Clothing","Favorite Season","Favorite Animal","Favorite App","Favorite Car"]
    let arr_right_interests = ["Lasagna","Purple","Pop","Sci-Fi","Comfy","Spring","Panda","SheDistrict","Mercedes"]
        
    var user_idFriend = ""
    
    var arrInfoTitle = [String]()
    var arrInfoValue = [String]()
    
    var isUploadedPhotos = false
    var selectedUserPhotos:UserPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        for i in 0..<btnUserActions.count {
            btnUserActions[i].tag = i
            btnUserActions[i].addTarget(self, action:#selector(btnUserActions(_:)), for:.touchUpInside)
        }
        
        if user_idFriend == signUp!.userID {
            for i in 0..<btnUserActions.count {
                if i != 1 {
                    btnUserActions[i].isHidden = true
                }
            }
        }
        
        func_API_get_user_profile()
    }
    
    @IBAction func btnUserActions(_ sender:UIButton) {
        if sender.tag == 0 {
            if getUserProfile?.isUserLike == "1" {
                func_API_dis_like()
            } else {
                func_API_do_like()
            }
        } else if sender.tag == 1 {
            let btn = UIButton()
            btn.tag = 1
            
            funcVerificationSuccessfully()
        } else if sender.tag == 2 {
            let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
            let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
            chat_VC.user = User (userID:getUserProfile!.userID, userProfile:getUserProfile!.userProfile, userName:getUserProfile!.userName, userEmail:"", userPassword: "", userCountryCode: "", userMobile: "", userDob: "", userLoginType: "", userSocial: "", userDeviceType: "", userDeviceToken: "", userLat: "", userLang: "", userStatus: "", created:getUserProfile!.created)
            navigationController?.pushViewController(chat_VC, animated: true)
        } else if sender.tag == 3 {
            btn_Report(sender)
        }
        
    }
    
}



extension MyProfileDetailsVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:80, height:80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if getUserProfile?.userPhotos == nil {
            return 0
        }
        return (getUserProfile?.userPhotos.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Search_CollectionCell
        
        cell.img_user.layer.borderColor = hexStringToUIColor(arr_border_color[indexPath.row]) .cgColor
        cell.img_user.layer.borderWidth = 2
        
        let userPhotos = k_Base_URL_Imgae+(getUserProfile?.userPhotos[indexPath.row].userPhotos)!
        cell.img_user.sd_setImage(with: URL(string:userPhotos), placeholderImage:k_default_user)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if user_idFriend == signUp!.userID {
            isUploadedPhotos = true
            selectedUserPhotos = getUserProfile?.userPhotos[indexPath.row]
            funcShowFullPicture((getUserProfile?.userPhotos[indexPath.row].userPhotos.userProfile)!,3)
        } else {
            isUploadedPhotos = false
            funcShowFullPicture((getUserProfile?.userPhotos[indexPath.row].userPhotos.userProfile)!,1)
        }
        
    }
    
    @IBAction func btnFullImageVC(_ sender: Any) {
        isUploadedPhotos = false
        if user_idFriend == signUp!.userID {
            funcShowFullPicture(getUserProfile!.userProfile.userProfile,2)
        } else {
            funcShowFullPicture(getUserProfile!.userProfile.userProfile,1)
        }
    }
    
}

//
//
//extension MyProfileDetailsVC:UITableViewDelegate,UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrInfoValue.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//
//        let lbl_left = cell.viewWithTag(1) as? UILabel
//        let lbl_right = cell.viewWithTag(2) as? UILabel
//
//        lbl_left?.text = arrInfoTitle[indexPath.row]
//        lbl_right?.text = arrInfoValue[indexPath.row]
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let animation = AnimationFactory.makeSlideIn(duration:0.15, delayFactor:0.01)
//        let animator = Animator(animation: animation)
//        animator.animate(cell: cell, at: indexPath, in: tableView)
//    }
//
//}



//MARK:- API methods
import KRProgressHUD

extension MyProfileDetailsVC {
    func func_API_get_user_profile() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":user_idFriend,
                    "friend_id":"\(signUp!.userID)"]
        
        print(param)
        
        APIFunc.postAPI("get_user_profile", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getUserProfile = try decoder.decode(GetUserProfile.self, from: jsonData)
                            self.funcUpdateUI()
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                hud.showError(withMessage: "\(error.localizedDescription)")
                            })
                        }
                    }
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
    
    func func_API_do_like() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["friend_id":user_idFriend,
                    "user_id":"\(signUp!.userID)"]
        print(param)
        
        APIFunc.postAPI("do_like", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                switch status {
                case success_resp:
                    getUserProfile?.isUserLike = "1"
                    self.btnUserActions[0].isSelected = true
                case failed_resp:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage: "\(json["message"])")
                    })
                default:
                    break
                }
            }
        }
    }
    
    func func_API_dis_like() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["friend_id":user_idFriend,
                    "user_id":"\(signUp!.userID)"]
        print(param)
        
        APIFunc.postAPI("dis_like", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                switch status {
                case success_resp:
                    getUserProfile?.isUserLike = "0"
                    self.btnUserActions[0].isSelected = false
                case failed_resp:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage: "\(json["message"])")
                    })
                default:
                    break
                }
            }
        }
    }
    
    func func_API_user_block() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
                
        let param = ["user_id":"\(signUp!.userID)",
                    "block_user_id":user_idFriend,
                    "reason":""]
        print(param)
        
        APIFunc.postAPI("user_block", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                switch status {
                case success_resp:
                    self.blockMessage()
                case failed_resp:
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        hud.showError(withMessage: "\(json["message"])")
                    })
                default:
                    break
                }
            }
        }
    }
    
    func funcUpdateUI() {
        imgUserProfile.sd_setImage(with: URL(string:getUserProfile!.userProfile.userProfile), placeholderImage:k_default_user)
        
        lblTitle.text = "\(getUserProfile!.userName)'s Profile"
        lblAboutUser.text = "About me"//\(getUserProfile!.userName)"
        lblUserName.text = getUserProfile?.userName
        lblAbout.text = getUserProfile?.aboutMe
        lblImLookingForFriends.text = getUserProfile?.friendLike
        
        if (getUserProfile?.userDetails.count)! > 0 {
            lblBio.text = getUserProfile?.userDetails[0].userBio
        }
        
        topBio.constant = 16
        if lblBio.text!.isEmpty {
            topBio.constant = 0
        }
        
        topUserPhotos.constant = 20
        heightUserPhotos.constant = 80
        if getUserProfile?.userPhotos.count == 0 {
            topUserPhotos.constant = 0
            heightUserPhotos.constant = 0
        }
        
        if getUserProfile?.isUserLike == "1" {
            btnUserActions[0].isSelected = true
        } else {
            btnUserActions[0].isSelected = false
        }
        
        collUserPhoto.reloadData()
    }
    
}



//MARK:- all popup methods
extension MyProfileDetailsVC:Delegate_Report,Delegate_Report_Resion,Delegate_Block,Delegate_UnBlock {
    @IBAction func btn_Report(_ sender:UIButton) {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Report_ViewController") as! Report_ViewController
        delete_Sure_VC.delegate = self
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
        
    }
        
    func func_Report() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Report_Resion_ViewController") as! Report_Resion_ViewController
        delete_Sure_VC.friend_id = user_idFriend
        delete_Sure_VC.delegate = self
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
    }
    
    func func_Block() {
        func_API_user_block()
    }
    
    func func_select_resion() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Report_Message_VC") as! Report_Message_VC
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
    }
    
    func func_cancel_block() {
        btn_back("")
    }
    
    func func_Yes() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Paused_Conversation_VC") as! Paused_Conversation_VC
//        delete_Sure_VC.delegate = self
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
    }
    
    func func_No() {
        
    }
        
    func func_how_it_works() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "How_it_works_VC") as! How_it_works_VC
        //        delete_Sure_VC.delegate = self
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
    }
        
    func blockMessage() {
        let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
        let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Block_Message_VC") as! Block_Message_VC
        delete_Sure_VC.delegate = self
        self.addChild(delete_Sure_VC)
        
        delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(delete_Sure_VC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            delete_Sure_VC.view.transform = .identity
        })
    }
            
}



// MARK:- FullPictureVC
extension MyProfileDetailsVC:DelegateFullPictureVC {
    func funcShowFullPicture(_ imgUrl:String,_ buttonsShow:Int) {
        let storyboard = UIStoryboard (name: "Preference", bundle: nil)
        let fullPictureVC = storyboard.instantiateViewController(withIdentifier: "FullPictureVC") as! FullPictureVC
        fullPictureVC.delegate = self
        fullPictureVC.buttonsShow = buttonsShow
        if isUploadedPhotos {
            fullPictureVC.selectedUserPhotos = selectedUserPhotos
        }
        
        fullPictureVC.imgUrl = imgUrl
        self.addChild(fullPictureVC)
        
        fullPictureVC.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(fullPictureVC.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            fullPictureVC.view.transform = .identity
        })
    }
    
    func funcReplace() {
        func_API_get_user_profile()
    }
    
    
}



extension MyProfileDetailsVC:DelegateVerificationSuccessfully {
    func funcVerificationSuccessfully() {
        let storyboard = UIStoryboard (name: "Preference", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PersonalInfoInterestVC") as! PersonalInfoInterestVC
        self.addChild(vc)
        vc.user_idFriend = user_idFriend
        vc.view.transform = CGAffineTransform(scaleX:2, y:2)
        
        self.view.addSubview(vc.view)
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            vc.view.transform = .identity
        })
    }
    
    func func_DelegateVerificationCancel() {
        btn_back("")
    }
    
}
