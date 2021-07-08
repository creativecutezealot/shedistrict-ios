//  Announcements_VC.swift
//  SheDistrict
//  Created by appentus on 1/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import ISPageControl

class Announcements_VC: UIViewController {
    
    @IBOutlet weak var coll_announcement:UICollectionView!
    @IBOutlet weak var pageControl: ISPageControl!
    
    let arr_header = ["Shout of the day","","New in Town!"]
    let arr_content_image = ["Image College_1.png","","Home Image.png"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.radius = 5
        pageControl.padding = 10
        pageControl.inactiveTintColor = hexStringToUIColor("D9DADA")
        pageControl.currentPageTintColor =  hexStringToUIColor("9E9E9E")
        
        coll_announcement.delegate = self
        coll_announcement.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(funcRefresh), name: NSNotification.Name (rawValue:"funcRefresh"), object:nil)
        //        let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "Page_Home_VC") as! Page_Home_VC
        //        pageViewController.view.gestureRecognizers?.forEach({ (gesture) in
        //                    pageViewController.view.removeGestureRecognizer(gesture)
        //                })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        funcRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ViewControllerUtils.shared.hideActivityIndicator()
    }
    
    @objc func funcRefresh()  {
        func_get_announcements_API()
    }
    
    func func_get_announcements_API() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("get_announcements", ["type":selectedCateID]) { (json,status,message) in
            DispatchQueue.main.async {
                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    
                    var getAnnouncement_1:[GetAnnouncement] = []
                    
                    
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getAnnouncement.removeAll()
                            
                            getAnnouncement_1 = try decoder.decode([GetAnnouncement].self, from: jsonData)
                            
                            for i in 0..<getAnnouncement_1.count {
                                //                                if selectedCateID == getAnnouncement_1[i].announcementCategoryID {
                                getAnnouncement.append(getAnnouncement_1[i])
                                //                                }
                            }
                            
                            getAnnouncement = getAnnouncement.reversed()
                            self.pageControl.numberOfPages = getAnnouncement.count
                            self.coll_announcement.reloadData()
                            if getAnnouncement.count > 0{
                                self.coll_announcement.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                            }
                            ViewControllerUtils.shared.hideActivityIndicator()

                        } catch {
                            ViewControllerUtils.shared.hideActivityIndicator()
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



extension Announcements_VC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getAnnouncement.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if selectedCateID == "6" {
            collectionView.register(UINib(nibName: "AnnouncementFromCEO", bundle: nil), forCellWithReuseIdentifier: "cell-1")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell-1", for: indexPath) as! AnnouncementFromCEO
            
            cell.viewContainer.layer.borderWidth = 3
            cell.viewContainer.layer.borderColor = (hexStringToUIColor(getAnnouncement[indexPath.row].category[0].color)).cgColor
            
            cell.img_user_profile.tag = indexPath.row
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapUserImg(_:)))
            
            cell.img_user_profile.addGestureRecognizer(tapGesture)
            cell.img_user_profile.isUserInteractionEnabled = true
            
            if getAnnouncement.count > indexPath.row {
                let userDetails = getAnnouncement[indexPath.row].user
                
                if userDetails.count > 0 {
                    cell.lbl_user_name.text = getAnnouncement[indexPath.row].user[0].userName
                    let userProfile = getAnnouncement[indexPath.row].user[0].userProfile.userProfile
                    cell.img_user_profile.sd_setImage(with: URL(string:userProfile), placeholderImage:k_default_user)
                } else {
                    cell.lbl_user_name.text = ""
                    cell.img_user_profile.image = k_default_user
                }
                
                cell.lbl_time.text = getAnnouncement[indexPath.row].created.UTCToLocal
                
                if getAnnouncement[indexPath.row].category.count > 0 {
                    cell.lblTitle.text = getAnnouncement[indexPath.row].announcementTitle
                }
                
                let announcementImage = k_Base_URL_Imgae+getAnnouncement[indexPath.row].announcementImage
                cell.img_annoucement.sd_setImage(with: URL(string:announcementImage), placeholderImage:kDefaultLogo)
                cell.lbl_description.text = getAnnouncement[indexPath.row].announcementDesc
                
                cell.btn_chat.tag = indexPath.row
                cell.btn_chat.addTarget(self, action: #selector(btn_chat(_:)), for: .touchUpInside)
                if getAnnouncement[indexPath.row].user.count > 0{
                    cell.btnThreeDot.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    cell.btn_chat.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    cell.imgThreeDot.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    
                }
                
                cell.btnThreeDot.tag = indexPath.row
                cell.btnThreeDot.addTarget(self, action:#selector(btnThreeDot(_:)), for: .touchUpInside)
            }
            
            return cell
        } else {
            collectionView.register(UINib(nibName: "Announce_CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Announce_CollectionViewCell
            
            cell.viewContainer.layer.borderWidth = 3
            cell.viewContainer.layer.borderColor = (hexStringToUIColor(getAnnouncement[indexPath.row].category[0].color)).cgColor
            
            cell.img_user_profile.tag = indexPath.row
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapUserImg(_:)))
            
            cell.img_user_profile.addGestureRecognizer(tapGesture)
            cell.img_user_profile.isUserInteractionEnabled = true
            
            if getAnnouncement.count > indexPath.row {
                let userDetails = getAnnouncement[indexPath.row].user
                if userDetails.count > 0 {
                    cell.lbl_user_name.text = getAnnouncement[indexPath.row].user[0].userName
                    let userProfile = getAnnouncement[indexPath.row].user[0].userProfile.userProfile
                    cell.img_user_profile.sd_setImage(with: URL(string:userProfile), placeholderImage:k_default_user)
                } else {
                    cell.lbl_user_name.text = ""
                    cell.img_user_profile.image = k_default_user
                }
                
                cell.lbl_time.text = getAnnouncement[indexPath.row].created.UTCToLocal
                
                if getAnnouncement[indexPath.row].category.count > 0 {
                    cell.lblTitle.text = getAnnouncement[indexPath.row].announcementTitle
                }
                
                let announcementImage = k_Base_URL_Imgae+getAnnouncement[indexPath.row].announcementImage
                cell.img_annoucement.sd_setImage(with: URL(string:announcementImage), placeholderImage:kDefaultLogo)
                cell.lbl_description.text = getAnnouncement[indexPath.row].announcementDesc
                
                cell.btn_chat.tag = indexPath.row
                cell.btn_chat.addTarget(self, action: #selector(btn_chat(_:)), for: .touchUpInside)
                
                if getAnnouncement[indexPath.row].user.count > 0{
                    cell.btnThreeDot.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    cell.btn_chat.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    cell.imgThreeDot.alpha = (signUp?.userID == getAnnouncement[indexPath.row].user[0].userID) ? 0.0 : 1.0
                    
                }
                
                cell.btnThreeDot.tag = indexPath.row
                cell.btnThreeDot.addTarget(self, action:#selector(btnThreeDot(_:)), for: .touchUpInside)
                
            }
            
            return cell
        }
        
    }
    @objc func tapUserImg(_ sender:UITapGestureRecognizer){
        var tag = sender.view!.tag
        
        let userDetails = getAnnouncement[tag].user
        
        if userDetails.count > 0 {
            if userDetails[0].userID != signUp!.userID{
                let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
                let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
                profileDetailsVC.user_idFriend = getAnnouncement[tag].user[0].userID
                self.navigationController?.pushViewController(profileDetailsVC, animated: true)
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds
        return CGSize (width:size.width, height:size.height)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl.currentPage = Int(roundedIndex)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        get_details = getAnnouncement[indexPath.row]
        func_Next_VC_Main_1("Announcement_Details_VC")
    }
    
    @IBAction func btnThreeDot(_ sender:UIButton) {
        let userDetails = getAnnouncement[sender.tag].user
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"ThreeDotAnnouncement"), object:userDetails)
    }
    
    @IBAction func btn_chat(_ sender:UIButton) {
        let userDetails = getAnnouncement[sender.tag].user
        if userDetails.count > 0 {
            if signUp?.userID == getAnnouncement[sender.tag].user[0].userID {
                funcAlertController("Alert! \nIt's your ad")
            } else {
                let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
                let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
                chat_VC.user = getAnnouncement[sender.tag].user[0]
                navigationController?.pushViewController(chat_VC, animated: true)
            }
        } else {
            funcAlertController("This ad not have User,s details")
        }
        
    }
    
}

