//  Home_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/6/20.
//  Copyright © 2020 appentus. All rights reserved.
 

import UIKit
import SwiftyJSON


class Search_ViewController: UIViewController {
    @IBOutlet weak var tbl_search:UITableView!
    @IBOutlet weak var viewAll:UIView!
    @IBOutlet weak var btnViewAll:UIView!
    
    var arr_title = [String]()
    var arr_user = ["Image_girl.png","Image_girl_01.png","Image_girl_02.png","Image_girl_03.png","Image_girl_04.png",]
    
    var dictUserByPreference = [String:Any]()
    var arrDictUserByPreference = [String]()
    var arrDictUserByPreferenceValue = [Any]()
    
    var isViewAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(func_API_user_by_preference), name: NSNotification.Name (rawValue:"preference"), object:nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"MostCommonThings"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(btnSelectCollCell(_:)), name: NSNotification.Name (rawValue:"selectCollCell"), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(funcPushPreferenceDetails(_:)), name: NSNotification.Name (rawValue: "selectPref"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        arr_title.removeAll()
        dictUserByPreference = [String:Any]()
        arrDictUserByPreference = [String]()
        arrDictUserByPreferenceValue = [Any]()
        
        func_API_user_by_preference()
    }
    
    @IBAction func btn_preferences(_ sender:UIButton) {
        func_Next_VC_Preference("PrefViewController")
    }
    
    @IBAction func btnViewAll(_ sender:UIButton) {
        var frameViewAll = viewAll.frame
        frameViewAll.size.height = 0
        viewAll.frame = frameViewAll
                
        isViewAll = true
        tbl_search.reloadData()
        btnViewAll.isHidden = true
    }
    
}



extension Search_ViewController {
    @objc func funcPushPreferenceDetails(_ noti:Notification) {
        let sender = noti.object as! Int
        
        if arr_title.count > sender {
            let json = JSON(dictUserByPreference[arr_title[sender]] as! [[String:Any]])
            let decoder = JSONDecoder()
            if let jsonData = json.description.data(using: .utf8) {
                do {
                    let storyboard = UIStoryboard (name:"Preference", bundle:nil)
                    let pref = storyboard.instantiateViewController(withIdentifier:"PreferenceUsersVC") as! PreferenceUsersVC
                    
                    pref.prefSelectedUserAccordingPreference = try decoder.decode([UserAccordingPreference].self, from: jsonData)
                    pref.userPreference = arr_title[sender]
                    navigationController?.pushViewController(pref, animated:true)
                } catch {
                    
                }
            }
        }
            
    }
    
}


extension Search_ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isViewAll {
            return arr_title.count
        } else {
            if arr_title.count < 3 {
                return arr_title.count
            } else {
                return 3
            }
        }
    }

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Search_TableViewCell
                
        if arr_title.count > indexPath.row {
            if indexPath.row == 0 {
                if arr_title[indexPath.row] == "Most_Things_in_Common" {
                    var fullString = ""
                    let arrMostCommonThings = dictUserByPreference[arr_title[indexPath.row]] as! [[String:Any]]
                    if arrMostCommonThings.count > 9 {
                         fullString = "Most Things in Common (10 or More)"
                    } else {
                         fullString = "Most Things in Common"
                    }
                    
                    let fontBold = UIFont (name:"Roboto-Medium", size: 14)
                    let fontRegular = UIFont (name:"Roboto-Regular", size: 14)
                    let attr_string = boldWithRange(fullString,"Most Things in Common", fontRegular, fontBold)
                                         
                    cell.lbl_title.attributedText = attr_string
                } else {
                    cell.lbl_title.text = arr_title[indexPath.row].replacingOccurrences(of:"_", with:" ")
                }
            } else {
                cell.lbl_title.text = arr_title[indexPath.row].replacingOccurrences(of:"_", with:" ")
            }
            
            let json = JSON(dictUserByPreference[arr_title[indexPath.row]] as! [[String:Any]])
            let decoder = JSONDecoder()
            if let jsonData = json.description.data(using: .utf8) {
                do {
                    userAccordingPreference = try decoder.decode([UserAccordingPreference].self, from: jsonData)
//                    cell.coll_search.delegate = self
//                    cell.coll_search.dataSource = self
                    cell.coll_search.tag = indexPath.row
                    
                    cell.coll_search.reloadData()
                } catch {
                    
                }
            }
        }
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       cell.alpha = 0
        UIView.animate(withDuration:0.25, delay:0.01, animations: {
               cell.alpha = 1
       })
    }
    
    @objc func btnSelectCollCell(_ sender:Notification) {
        let btn = sender.object as! UIButton
            let buttonPosition:CGPoint = btn.convert(CGPoint.zero, to:self.tbl_search)
            let indexPath = self.tbl_search.indexPathForRow(at: buttonPosition)
                                    
            if arr_title.count > indexPath!.row {
                let json = JSON(dictUserByPreference[arr_title[indexPath!.row]] as! [[String:Any]])
                let decoder = JSONDecoder()
                if let jsonData = json.description.data(using: .utf8) {
                    do {
                        userAccordingPreference = try decoder.decode([UserAccordingPreference].self, from: jsonData)
                        
                        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
                        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
                        profileDetailsVC.user_idFriend = userAccordingPreference[btn.tag].userID
                        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
                    } catch {
                        
                    }
                }
            }
        }
    
}



//MARK:- API methods
import KRProgressHUD

extension Search_ViewController {
    @objc func func_API_user_by_preference() {
        let hud = KRProgressHUD.showOn(self)
        
        ViewControllerUtils.shared.showActivityIndicator()
        let param = dictPreferecenes.isEmpty ? ["user_id":signUp!.userID] : ["user_id":signUp!.userID,"filter":dictPreferecenes.json]
        print(param)
        
        APIFunc.postAPI("user_by_preference", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()
                
                dictPreferecenes.removeAll()
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    self.dictUserByPreference = json.dictionaryObject!["result"] as! [String:Any]
                    print(self.dictUserByPreference)
                    self.arr_title.removeAll()
                    for (key,value) in self.dictUserByPreference {
                        self.arr_title.append(key)
                        self.arrDictUserByPreferenceValue.append(value)
                    }
                    
                    if self.arr_title.contains("Most_Things_in_Common") {
                        self.arr_title.swapAt(0, self.arr_title.firstIndex(of:"Most_Things_in_Common")!)
                    }
                    
                    var arrTitleValue = self.arr_title
                    for i in 0..<self.arr_title.count {
                        let arrMostCommonThings = self.dictUserByPreference[self.arr_title[i]] as! [[String:Any]]
                        if arrMostCommonThings.count == 0 {
                            arrTitleValue.remove(at:arrTitleValue.firstIndex(of:self.arr_title[i])!)
                        }
                    }
                    self.arr_title = arrTitleValue
                    
                    var frameViewAll = self.viewAll.frame
                    frameViewAll.size.height = 75
                    self.viewAll.frame = frameViewAll
                    
                    self.btnViewAll.isHidden = false
                    self.isViewAll = false
                    self.tbl_search.reloadData()
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


