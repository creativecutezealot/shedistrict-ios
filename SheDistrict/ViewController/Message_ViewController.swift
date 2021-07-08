//  Home_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import CoreLocation
import KRProgressHUD
import SDWebImage


class Message_ViewController: UIViewController {
    @IBOutlet weak var coll_friends_list:UICollectionView!
    @IBOutlet weak var tbl_chat_list:UITableView!
    @IBOutlet weak var tblFriendList:UITableView!
    
    @IBOutlet weak var viewFriendList:UIView!
    
    @IBOutlet weak var height_friend_list:NSLayoutConstraint!
    @IBOutlet weak var btn_number_of_friends:UIButton!
    
    var co_OrdinateCurrent = CLLocationCoordinate2DMake(0.0, 0.0)
    var locationManager = CLLocationManager()
    var is_location = false
    
    var isFriendList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFriendList.removeAll()
        chatList.removeAll()
        
        NotificationCenter.default.addObserver(self, selector:#selector(func_chat_list), name:NSNotification.Name(rawValue:"newMessage"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        is_location = false
        
        btn_number_of_friends.isHidden = true
        height_friend_list.constant = 0
        
        func_core_location()
        func_chat_list()
    }
    
    func funcViewFriendList() {
        viewFriendList.frame = self.view.frame
        self.view.addSubview(viewFriendList)
        
        tblFriendList.layer.cornerRadius = 10
        tblFriendList.clipsToBounds = true
        
        viewFriendList.isHidden = true
    }
    
    @IBAction func btnRemoveFriendList(_ sender:UIButton) {
        isFriendList = false
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping:0.5, initialSpringVelocity: 0, options: [], animations: {
            self.viewFriendList.transform = CGAffineTransform(scaleX:0.02, y: 0.02)
        }) { (success) in
            self.viewFriendList.isHidden = true
        }
    }
    //    ./assets/uploads/ce01c5a87d31c10da86b2b17ba301c76image.jpeg
    @IBAction func btnEmailIcon(_ sender:UIButton) {
        isFriendList = true
        viewFriendList.isHidden = false
        viewFriendList.transform = CGAffineTransform(scaleX:2, y:2)
        tblFriendList.reloadData()
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            self.viewFriendList.transform = .identity
        })
    }
    
    func func_get_friend_list() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let param = ["user_lat":"\(co_OrdinateCurrent.latitude)",
            "user_lang":"\(co_OrdinateCurrent.longitude)",
            "user_id":signUp!.userID]
        APIFunc.postAPI("get_friend_list",param) { (json,status,message)  in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getFriendList = try decoder.decode([GetFriendList].self, from: jsonData)
                            if getFriendList.count > 0 {
                                self.height_friend_list.constant = 80
                                self.btn_number_of_friends.isHidden = false
                                self.btn_number_of_friends.setTitle("\(getFriendList.count)", for: .normal)
                                
                                if getFriendList.count > 0 {
                                    self.funcViewFriendList()
                                }
                                
                                UIView.animate(withDuration: 0.3) {
                                    self.view.layoutIfNeeded()
                                }
                            }
                            self.coll_friends_list.reloadData()
                        } catch {
                            print(error.localizedDescription)
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
    
    @objc func func_chat_list() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let param = ["user_id":signUp?.userID]  as! [String : String]
        APIFunc.postAPI("chat_list",param) { (json,status,message)  in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            chatList = try decoder.decode([ChatList].self, from: jsonData)
                            self.tbl_chat_list.reloadData()
                        } catch {
                            print(error.localizedDescription)
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
    
}



extension Message_ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tbl_chat_list {
            return chatList.count
        } else {
            return getFriendList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Message_TableViewCell
        
        cell.btn_select.tag = indexPath.row
        cell.btn_select.addTarget(self, action: #selector(btn_select(_:)), for: .touchUpInside)
        
        if tableView == tbl_chat_list {
            cell.img_user_profile.sd_setImage(with: URL(string:k_Base_URL_Imgae+chatList[indexPath.row].friImage), placeholderImage:k_default_user)
            cell.lbl_user_name.text = chatList[indexPath.row].friName
            cell.lbl_last_message.text = chatList[indexPath.row].lastMessage.fromBase64()
            cell.lbl_time.text = chatList[indexPath.row].lastMessageCreated.UTCToLocal
            
            cell.lbl_last_message.isHidden = false
            cell.img_user_profile.tag = indexPath.row
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapUserImg(_:)))
            
            cell.img_user_profile.addGestureRecognizer(tapGesture)
            cell.img_user_profile.isUserInteractionEnabled = true
        } else {
            cell.img_user_profile.sd_setImage(with: URL(string:getFriendList[indexPath.row].userProfile.userProfile), placeholderImage:k_default_user)
            cell.lbl_user_name.text = getFriendList[indexPath.row].userName
            cell.lbl_last_message.isHidden = true
            cell.lbl_time.text = getFriendList[indexPath.row].created.UTCToLocal
        }
        
        return cell
    }
    
    @objc func tapUserImg(_ sender:UITapGestureRecognizer){
        var tag = sender.view!.tag
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = chatList[tag].newFriID
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
        
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        let animation = AnimationFactory.makeSlideIn(duration:0.25, delayFactor:0.01)
    //        let animator = Animator(animation: animation)
    //        animator.animate(cell: cell, at: indexPath, in: tableView)
    //    }
    
    @IBAction func btn_select(_ sender:UIButton) {
        let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
        let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
        
        if !isFriendList {
            let chatlist_data = chatList[sender.tag]
            chat_VC.user = User (userID: chatlist_data.newFriID, userProfile: chatlist_data.friImage, userName: chatlist_data.friName, userEmail:"", userPassword: "", userCountryCode: "", userMobile: "", userDob: "", userLoginType: "", userSocial: "", userDeviceType: "", userDeviceToken: "", userLat: "", userLang: "", userStatus: "", created:chatlist_data.lastMessageCreated)
        } else {
            let chatlist_data = getFriendList[sender.tag]
            chat_VC.user = User (userID: chatlist_data.userID, userProfile: chatlist_data.userProfile, userName: chatlist_data.userName, userEmail:chatlist_data.userEmail, userPassword:chatlist_data.userPassword, userCountryCode:chatlist_data.userCountryCode, userMobile:chatlist_data.userMobile, userDob:chatlist_data.userDob, userLoginType:chatlist_data.userLoginType, userSocial:chatlist_data.userSocial, userDeviceType:chatlist_data.userDeviceType, userDeviceToken:"", userLat:"", userLang:"", userStatus:"", created:"")
        }
        
        navigationController?.pushViewController(chat_VC, animated: true)
    }
    
}



extension Message_ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:80, height:80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getFriendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Search_CollectionCell
        
        if getFriendList.count > indexPath.row {
            cell.img_user.sd_setImage(with: URL(string:getFriendList[indexPath.row].userProfile.userProfile), placeholderImage:k_default_user)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
        let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
        
        let chatlist_data = getFriendList[indexPath.row]
        chat_VC.user = User (userID: chatlist_data.userID, userProfile: chatlist_data.userProfile, userName: chatlist_data.userName, userEmail:chatlist_data.userEmail, userPassword:chatlist_data.userPassword, userCountryCode:chatlist_data.userCountryCode, userMobile:chatlist_data.userMobile, userDob:chatlist_data.userDob, userLoginType:chatlist_data.userLoginType, userSocial:chatlist_data.userSocial, userDeviceType:chatlist_data.userDeviceType, userDeviceToken:"", userLat:"", userLang:"", userStatus:"", created:"")
        
        navigationController?.pushViewController(chat_VC, animated: true)
    }
    
}



extension Message_ViewController:CLLocationManagerDelegate {
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        viewFriendList.removeFromSuperview()
    }
    
    func func_core_location() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        co_OrdinateCurrent = manager.location!.coordinate
        
        if !is_location {
            is_location = true
            func_get_friend_list()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
}


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}
