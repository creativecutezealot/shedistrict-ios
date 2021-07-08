//  UsersAnnouncementDetails.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import ISPageControl


class UsersAnnouncementDetails: UIViewController {
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
        
//        pageControl.borderWidth = 1
//        pageControl.borderColor = UIColor.blue
                
        coll_announcement.delegate = self
        coll_announcement.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(funcRefresh), name: NSNotification.Name (rawValue:"funcRefresh"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        funcRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ViewControllerUtils.shared.hideActivityIndicator()
    }
    
    @objc func funcRefresh()  {
        getAnnouncement.removeAll()
        func_get_announcements_API()
    }
    
    func func_get_announcements_API() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        APIFunc.postAPI("get_announcements", ["type":""]) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getAnnouncement = try decoder.decode([GetAnnouncement].self, from: jsonData)
                            getAnnouncement = getAnnouncement.reversed()
                            self.coll_announcement.reloadData()
                            self.pageControl.numberOfPages = getAnnouncement.count
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



extension UsersAnnouncementDetails:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getAnnouncement.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            collectionView.register(UINib(nibName: "UsersAnnouncementDetailsCVC", bundle: nil), forCellWithReuseIdentifier: "cell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! UsersAnnouncementDetailsCVC
            
            if getAnnouncement.count > indexPath.row {
//                let userDetails = getAnnouncement[indexPath.row].user
//                if userDetails.count > 0 {
//                    cell.lbl_user_name.text = getAnnouncement[indexPath.row].user[0].userName
//                    let userProfile = getAnnouncement[indexPath.row].user[0].userProfile.userProfile
//                    cell.img_user_profile.sd_setImage(with: URL(string:userProfile), placeholderImage:k_default_user)
//                } else {
//                    cell.lbl_user_name.text = ""
//                    cell.img_user_profile.image = k_default_user
//                }
                
                cell.lbl_time.text = getAnnouncement[indexPath.row].created.UTCToLocal
                
                if getAnnouncement[indexPath.row].category.count > 0 {
                    cell.lbl_category.text = getAnnouncement[indexPath.row].category[0].categoryName
                }
                
                let announcementImage = k_Base_URL_Imgae+getAnnouncement[indexPath.row].announcementImage
                cell.img_annoucement.sd_setImage(with: URL(string:announcementImage), placeholderImage:kDefaultLogo)
                cell.lbl_description.text = getAnnouncement[indexPath.row].announcementDesc
                
//                cell.btn_chat.tag = indexPath.row
//                cell.btn_chat.addTarget(self, action: #selector(btn_chat(_:)), for: .touchUpInside)
                
                cell.btnThreeDot.tag = indexPath.row
                cell.btnThreeDot.addTarget(self, action:#selector(btnThreeDot(_:)), for: .touchUpInside)
            }
            
            return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds
        return CGSize (width:size.width, height:size.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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

