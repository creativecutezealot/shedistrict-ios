//  Chat_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/8/20.
//  Copyright © 2020 appentus. All rights reserved.



import UIKit
import IQKeyboardManagerSwift
import KRProgressHUD
import SDWebImage
import AVKit
import MobileCoreServices


class Chat_ViewController: UIViewController {
    @IBOutlet weak var tbl_chat:UITableView!
    @IBOutlet weak var txt_type_something:UITextView!
    @IBOutlet weak var view_type_something:UIView!
    
    @IBOutlet weak var height_txt_type_something:NSLayoutConstraint!
    @IBOutlet weak var height_container:NSLayoutConstraint!
    @IBOutlet weak var bottom_message_text:NSLayoutConstraint!
    
    @IBOutlet weak var lbl_user_name:UILabel!
    
    var user:User?
    var isMessageDraft = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt_type_something.returnKeyType = .done
        
        func_keyboard()
        
        lbl_user_name.text = user?.userName
        
        txt_type_something.delegate = self
        
        if let messageDraft = UserDefaults.standard.object(forKey:"messageDraft") as? [String:String] {
            if let txtmessageDraft = messageDraft[user!.userID] {
                if txtmessageDraft.isEmpty {
                    txt_type_something.text = "Type something..."
                    txt_type_something.textColor = hexStringToUIColor("C2C2C2")
                } else {
                    txt_type_something.text = txtmessageDraft
                    txt_type_something.textColor = UIColor .black
                }
                
                funcSetHeightOfType_something()
            }
        }
            
        getMessage.removeAll()
        func_get_message()
        NotificationCenter.default.addObserver(self, selector:#selector(func_get_message), name:NSNotification.Name(rawValue:"newMessage"), object:nil)
    }
    
    
    
    @IBAction func btn_report(_ sender:UIButton) {
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
    
    @IBAction func btn_camera(_ sender:UIButton) {
        self.view.endEditing(true)
        
        func_ChooseImage(sender)
        view_type_something.func_success_shadow()
    }
    
    @IBAction func btn_send(_ sender:UIButton) {
        isMessageDraft = false
        self.view.endEditing(true)
        
        if txt_type_something.text.isEmpty || txt_type_something.text == "Type something..." || !(txt_type_something.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
            height_container.constant = 70
            height_txt_type_something.constant = 40
            return
        }
        
        func_send_message("","")
        
        var dictMessageDraft = [String:String]()
        
        if let messageDraft = UserDefaults.standard.object(forKey:"messageDraft") as? [String:String] {
            dictMessageDraft = messageDraft
            dictMessageDraft[user!.userID] = ""
        } else {
            dictMessageDraft[user!.userID] = ""
        }
        
        UserDefaults.standard.set(dictMessageDraft, forKey:"messageDraft")
    }
    
    @IBAction func btn_view_profile(_ sender:UIButton) {
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = user!.userID
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
    }
                
}



//MARK:- all API methods
extension Chat_ViewController {
    func scrollToRow() {
        if getMessage.count > 2 {
            self.tbl_chat.scrollToRow(at:IndexPath(row:getMessage.count-1, section:0), at:.bottom, animated:false)
        }
    }
    
    func func_send_message(_ chat_file:Any,_ chat_file_type:String) {
        var data = Data()
        if chat_file_type == "1" {
            let img_chat_file = chat_file as! UIImage
            data = img_chat_file.jpegData(compressionQuality: 0.2)!
            
            func_API_image(data)
        } else if chat_file_type == "2" {
            let video_url = chat_file as! URL
            do {
                data = try Data (contentsOf:video_url)
            } catch {
                print(error.localizedDescription)
            }
            func_API_video(data)
        } else {
            func_API_text()
        }
        
    }
    
    @objc func func_get_message() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":signUp?.userID,
                     "fri_id":user?.userID] as! [String : String]
        print(param)
        
        APIFunc.postAPI("get_message", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            getMessage = try decoder.decode([GetMessage].self, from: jsonData)
                            
                            self.tbl_chat.reloadData()
                            self.scrollToRow()
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
    
    func func_API_text() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":"\(signUp!.userID)",
                     "fri_id":"\(user!.userID)",
                     "message":txt_type_something.text!]
        print(param)
        
        APIFunc.postAPI("send_message", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                        self.txt_type_something.text = "Type something..."
                        self.txt_type_something.textColor = hexStringToUIColor("C2C2C2")
                        
                        let dictResult = json.dictionaryObject![result_resp] as! [String:Any]
                        getMessage.append(GetMessage(dictionary:dictResult)!)
                        
                        self.tbl_chat.reloadData()
                        
                        self.scrollToRow()
                        self.resetTypeSometing()
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
    
    func func_API_image(_ data:Data) {
        let hud = KRProgressHUD.showOn(self)
         ViewControllerUtils.shared.showActivityIndicator()
         
         let param = ["user_id":"\(signUp!.userID)",
                      "fri_id":"\(user!.userID)",
                      "message":""]
         print(param)
        
        APIFunc.postAPI_Image("send_message",data,param, "file") { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    self.txt_type_something.text = "Type something..."
                    self.txt_type_something.textColor = hexStringToUIColor("C2C2C2")
                    
                    let dictResult = json.dictionaryObject![result_resp] as! [String:Any]
                    getMessage.append(GetMessage(dictionary:dictResult)!)
                    
                    self.tbl_chat.reloadData()
                    self.scrollToRow()
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
    
    func func_API_video(_ data:Data) {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":"\(signUp!.userID)",
                    "fri_id":"\(user!.userID)",
                    "message":""]
        print(param)
        
        APIFunc.postAPI_Video("send_message",data,param, "file") { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    self.txt_type_something.text = "Type something..."
                    self.txt_type_something.textColor = hexStringToUIColor("C2C2C2")
                    
                    let dictResult = json.dictionaryObject![result_resp] as! [String:Any]
                    getMessage.append(GetMessage(dictionary:dictResult)!)
                    
                    self.tbl_chat.reloadData()
                    self.scrollToRow()
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
    
//    func apiSendData(_ dictResult:[String:String]) {
//        var dictGetMessage = dict
//        dictGetMessage["friendprofile"] =
//
//        GetMessage (dictionary:)
//    }
    
    func func_API_user_block() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
                
        let param = ["user_id":"\(signUp!.userID)",
                    "block_user_id":"\(user!.userID)",
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
    
    
}



//MARK:- keyboard
extension Chat_ViewController {
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    
    func func_keyboard() {
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
//            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(func_cancel)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(func_cancel))
        ]
        numberToolbar.sizeToFit()
        txt_type_something.inputAccessoryView = numberToolbar
        
        tbl_chat.reloadData()
        scrollToRow()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
               let keyboardHeight = keyboardRectValue.height
            func_set_bottom(keyboardHeight+20)
            if getMessage.count > 0{
                self.tbl_chat.scrollToRow(at: IndexPath(row: getMessage.count-1, section: 0), at: .bottom, animated: true)
            }
           }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        func_set_bottom(20)
    }
    
    func func_set_bottom(_ bottom:CGFloat) {
        bottom_message_text.constant = bottom
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func func_cancel() {
        self.view.endEditing(true)
    }
    
}

// MARK:- tablview delegate
extension Chat_ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if getMessage[indexPath.row].chatFileType == "0" {
            let calculated_height = getMessage[indexPath.row].chatMessage!.height_According_Text(self.view.bounds.width-160,UIFont (name:"Roboto-Light", size:13.0)!)+100
            if calculated_height < 105 {
                return 100
            } else {
                return calculated_height
            }
        } else if getMessage[indexPath.row].chatFileType == "1" {
            return 222
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if getMessage[indexPath.row].chatFileType == "0" {
//            return whiteTableViewCell(indexPath)
            
            if signUp!.userID == getMessage[indexPath.row].userID{
                let cell = tbl_chat.dequeueReusableCell(withIdentifier:"cell_white", for: indexPath) as! Chat_White_TableCell
                cell.view_container.semanticContentAttribute = .forceRightToLeft
                cell.view_container_chat.semanticContentAttribute = .forceRightToLeft
                cell.view_container_chat.backgroundColor = hexStringToUIColor("ED60A9")
                cell.lbl_time.textAlignment = .left
                
                cell.lbl_chat.textColor = UIColor.white
                cell.lbl_time.textColor = UIColor.white
                cell.lbl_sent.textColor = UIColor.white
                cell.lbl_sent.isHidden = false
                cell.lbl_chat.text = getMessage[indexPath.row].chatMessage!.fromBase64()
                cell.lbl_time.text = getMessage[indexPath.row].created?.timeFormat//?.UTCToLocal
                cell.img_user_profile.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: k_Base_URL_Imgae+signUp!.userProfile)), placeholderImage:k_default_user)
                cell.widthText.constant = (getMessage[indexPath.row].chatMessage?.sizeAccordingText(self.view.bounds.width,UIFont (name:"Roboto-Light", size:13.0)!).width)!+77+20
                if cell.widthText.constant > self.view.bounds.width - 100 {
                    cell.widthText.constant = self.view.bounds.width - 100
                }
                
                return cell
            }else{
                let cell = tbl_chat.dequeueReusableCell(withIdentifier:"cell_white", for: indexPath) as! Chat_White_TableCell
                cell.view_container.semanticContentAttribute = .forceLeftToRight
                cell.view_container_chat.semanticContentAttribute = .forceLeftToRight
                cell.view_container_chat.backgroundColor = UIColor .white
                cell.lbl_time.textAlignment = .right
                cell.lbl_chat.textColor = UIColor.black
                cell.lbl_time.textColor = UIColor.black
                cell.lbl_sent.textColor = UIColor.black
                cell.lbl_sent.isHidden = true
                cell.img_user_profile.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: getMessage[indexPath.row].userprofile!.userProfile)), placeholderImage:k_default_user)
                cell.lbl_chat.text = getMessage[indexPath.row].chatMessage!.fromBase64()
                cell.lbl_time.text = getMessage[indexPath.row].created?.timeFormat//?.UTCToLocal
                cell.widthText.constant = (getMessage[indexPath.row].chatMessage?.sizeAccordingText(self.view.bounds.width,UIFont (name:"Roboto-Light", size:13.0)!).width)!+77+20
                if cell.widthText.constant > self.view.bounds.width - 100 {
                    cell.widthText.constant = self.view.bounds.width - 100
                }
                return cell
            }
            
            
            
            
        } else if getMessage[indexPath.row].chatFileType == "1" {
            return imageTableViewCell(indexPath)
        } else {
            return imageTableViewCell(indexPath) // is line ka ab tak koi use nhi h
        }
        
    }
    
    
    func imageTableViewCell(_ indexPath:IndexPath) -> UITableViewCell {
         let cell = tbl_chat.dequeueReusableCell(withIdentifier:"cell-image", for: indexPath) as! Chat_White_TableCell
         
         if signUp!.userID != getMessage[indexPath.row].userID {
             cell.view_container.semanticContentAttribute = .forceLeftToRight
             cell.view_container_chat.semanticContentAttribute = .forceLeftToRight
             cell.view_container_chat.backgroundColor = UIColor .white
             cell.lbl_time.textAlignment = .right
             cell.lbl_chat.textColor = UIColor.black
             cell.lbl_time.textColor = UIColor.black
             cell.lbl_sent.textColor = UIColor.black
             cell.lbl_sent.isHidden = true
             cell.img_user_profile.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: getMessage[indexPath.row].userprofile!.userProfile)), placeholderImage:k_default_user)

         } else {
             cell.view_container.semanticContentAttribute = .forceRightToLeft
             cell.view_container_chat.semanticContentAttribute = .forceRightToLeft
             cell.view_container_chat.backgroundColor = hexStringToUIColor("ED60A9")
             cell.lbl_time.textAlignment = .left
             
             cell.lbl_chat.textColor = UIColor.white
             cell.lbl_time.textColor = UIColor.white
             cell.lbl_sent.textColor = UIColor.white
             cell.lbl_sent.isHidden = false
             cell.img_user_profile.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: signUp!.userProfile.userProfile) ), placeholderImage:k_default_user)

         }
        
        cell.img_chat.sd_setImage(with: URL(string:fixEmptySpaceForUrl(stringCurrent: k_Base_URL_Imgae+getMessage[indexPath.row].chatFile!)), placeholderImage:nil)
        cell.lbl_time.text = getMessage[indexPath.row].created?.timeFormat//?.UTCToLocal
        cell.btn_image_chat.tag = indexPath.row
        cell.btn_image_chat.addTarget(self, action:#selector(btn_image_chat(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
         UIView.animate(withDuration:0.25, delay:0.01, animations: {
             cell.alpha = 1
         })
    }
    
    @IBAction func btn_image_chat(_ sender:UIButton) {
        funcImageChatOpen(k_Base_URL_Imgae+(getMessage[sender.tag].chatFile ?? ""))
    }
    
}

// MARK:- textview delegate
extension Chat_ViewController:UITextViewDelegate,UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isMessageDraft = true
        
        if textView.text == "Type something..." {
            textView.text = ""
            textView.textColor = UIColor .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        var dictMessageDraft = [String:String]()
        
        if let messageDraft = UserDefaults.standard.object(forKey:"messageDraft") as? [String:String] {
            dictMessageDraft = messageDraft
            if isMessageDraft {
                dictMessageDraft[user!.userID] = textView.text!
            } else {
                dictMessageDraft[user!.userID] = ""
            }
        } else {
            if isMessageDraft {
                dictMessageDraft[user!.userID] = textView.text!
            } else {
                dictMessageDraft[user!.userID] = ""
            }
        }
        
        UserDefaults.standard.set(dictMessageDraft, forKey:"messageDraft")
        
        if textView.text == "" || !(txt_type_something.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0) {
            textView.text = "Type something..."
            textView.textColor = hexStringToUIColor("C2C2C2")
            resetTypeSometing()
        }
    }
    
    func resetTypeSometing() {
        height_container.constant = 70
        height_txt_type_something.constant = 40
        
        UIView.animate(withDuration:0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            let btn = UIButton()
            btn_send(btn)
            return false
        }
        
        return true
    }
    
    func funcSetHeightOfType_something() {
        let height = txt_type_something.text.height_According_Text(self.view.bounds.width-66*2, UIFont (name:"Roboto", size:16.0)!)
        
        if height+40 < 70 {
            height_container.constant = 70
            height_txt_type_something.constant = 40
        } else {
            if height+40 < 134 {
                height_container.constant = height+40
                height_txt_type_something.constant = height+10
            }
        }
        
        if txt_type_something.text == "" {
            height_container.constant = 70
            height_txt_type_something.constant = 40
        }
        UIView.animate(withDuration:0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
            funcSetHeightOfType_something()
        
//        let height = txt_type_something.text.height_According_Text(self.view.bounds.width-66*2, UIFont (name:"Roboto", size:16.0)!)
//
//        if height+40 < 70 {
//            height_container.constant = 70
//            height_txt_type_something.constant = 40
//        } else {
//            if height+40 < 134 {
//                height_container.constant = height+40
//                height_txt_type_something.constant = height+10
//            }
//        }
//
//        if txt_type_something.text == "" {
//            height_container.constant = 70
//            height_txt_type_something.constant = 40
//        }
//
//        UIView.animate(withDuration:0.1) {
//            self.view.layoutIfNeeded()
//        }
    }
    
}



//MARK:- all popup methods
extension Chat_ViewController:Delegate_Report,Delegate_Report_Resion,Delegate_Block,Delegate_UnBlock {
        func func_Report() {
            let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
            let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "Report_Resion_ViewController") as! Report_Resion_ViewController
            delete_Sure_VC.friend_id = user!.userID
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
            
//            let storyboard = UIStoryboard (name: "PopUp", bundle: nil)
//            let delete_Sure_VC = storyboard.instantiateViewController(withIdentifier: "UnBlock_VC") as! UnBlock_VC
//            delete_Sure_VC.delegate = self
//            self.addChild(delete_Sure_VC)
//
//            delete_Sure_VC.view.transform = CGAffineTransform(scaleX:2, y:2)
//
//            self.view.addSubview(delete_Sure_VC.view)
//            UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
//                delete_Sure_VC.view.transform = .identity
//            })
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




extension Chat_ViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func func_camera_permission(completion:@escaping (Bool)->()) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    let alert = UIAlertController (title: "SheDistrict would like to access the camera", message: "SheDistrict needs Camera and PhotoLibrary to complete you profile", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Don't allow", style: .default) { (yes) in
                        
                    }
                    
                    let no = UIAlertAction(title: "Allow", style: .default) { (yes) in
                        DispatchQueue.main.async {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }
                    
                    alert.addAction(yes)
                    alert.addAction(no)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            completion(granted)
        }
    }
    
    @IBAction func func_ChooseImage(_ sender:UIButton) {
        let alert = UIAlertController(title: "", message: "Please select!", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.func_OpenCamera()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photos", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.func_OpenGallary()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            print("User click Delete button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func func_OpenCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.mediaTypes = ["public.image", "public.movie"]
//            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            func_camera_permission { (is_permission) in
                if is_permission {
                    DispatchQueue.main.async {
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert  = UIAlertController(title: "Warning!", message: "You don't have camera in simulator", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func func_OpenGallary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.mediaTypes = ["public.image", "public.movie"]
//        imagePicker.allowsEditing = true
        imagePicker.delegate=self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            func_send_message(pickedImage, "1")
        }
        
        if let picked_vedeo = info[.mediaURL] as? URL {
            func_send_message(picked_vedeo, "2")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

    func fixEmptySpaceForUrl(stringCurrent:String) -> String{
        let stringWithSpace = stringCurrent
        let stringWithoutSpace = stringWithSpace.replacingOccurrences(of: " ", with: "%20")
        return stringWithoutSpace
    }

