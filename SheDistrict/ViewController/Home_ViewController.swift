//  Home_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/6/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD


class Home_ViewController:UIViewController {
    @IBOutlet var btn_selected_announcements:[UIButton]!
    @IBOutlet weak var view_dot_selected:UIView!
    @IBOutlet weak var view_light_shadow:UIView!
    
    @IBOutlet weak var collCategory:UICollectionView!
    
    let arr_dot_selected = ["ffd200","E1E1E1"]
    
    var arrSelectAnnouncement = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.getAPI("post_category", [:]) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            postcategory = try decoder.decode([Postcategory].self, from: jsonData)
                            for i in 0..<postcategory.count {
                                if i == 0 {
                                    self.arrSelectAnnouncement.append(true)
                                    selectedColorAnnouncemenet = postcategory[i].color
                                    selectedCateID = postcategory[i].categoryID
                                } else {
                                    self.arrSelectAnnouncement.append(false)
                                }
                                if i == postcategory.count - 1{
                                    self.collCategory.reloadData()
                                }
                            }
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
        
        view_light_shadow.isHidden = true
        
        for i in 0..<btn_selected_announcements.count {
            btn_selected_announcements[i].tag = i+1
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(func_set_selected(noti:)),name:NSNotification.Name(rawValue:"selected_announcements"), object: nil)
    }
    
    @objc func func_set_selected(noti:Notification)  {
        let selected_tag = noti.object as! Int
        
        for i in 0..<btn_selected_announcements.count {
            if i == selected_tag {
                view_dot_selected.center.x = btn_selected_announcements[i].center.x
                btn_selected_announcements[selected_tag].setTitleColor(hexStringToUIColor(arr_dot_selected[0]), for:.normal)
            } else {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor(arr_dot_selected[1]), for:.normal)
            }
        }
    }
    
    @IBAction func btn_add_new_post(_ sender:Any) {
        func_Next_VC_Main_1("New_Post_VC")
    }
        
    @IBAction func btn_selected_announcements(_ sender:UIButton) {
        for i in 0..<btn_selected_announcements.count {
            if btn_selected_announcements[i].tag == sender.tag {
                view_dot_selected.center.x = btn_selected_announcements[i].center.x
                btn_selected_announcements[sender.tag-1].setTitleColor(hexStringToUIColor(arr_dot_selected[0]), for:.normal)
            } else {
                btn_selected_announcements[i].setTitleColor(hexStringToUIColor(arr_dot_selected[1]), for:.normal)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"move_by_buttons_home"), object: sender.tag-1)
    }
     
}



extension Home_ViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width/3
        return CGSize(width:width, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postcategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! AnnouncementCategoryCVC
        
        let cate = postcategory[indexPath.row]
        
        cell.lblCategory.backgroundColor = hexStringToUIColor(cate.color)
        cell.lblCategory.layer.cornerRadius = 15
        cell.lblCategory.clipsToBounds = true
        
        cell.lblCategory.text = cate.categoryName
        cell.lblCategory.textColor = arrSelectAnnouncement[indexPath.row] ? UIColor .white : UIColor.darkGray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<arrSelectAnnouncement.count {
            if i == indexPath.row {
                arrSelectAnnouncement[i] = true
                selectedColorAnnouncemenet = postcategory[i].color
                selectedCateID = postcategory[i].categoryID
            } else {
                arrSelectAnnouncement[i] = false
            }
        }
        collCategory.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "funcRefresh"), object:nil)
    }
    
}
