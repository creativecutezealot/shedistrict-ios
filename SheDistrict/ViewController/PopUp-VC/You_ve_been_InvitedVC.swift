//
//  You_ve_been_InvitedVC.swift
//  SheDistrict
//
//  Created by appentus on 1/10/20.
//  Copyright © 2020 appentus. All rights reserved.



protocol Delegate_You_ve_been_Invited {
    func func_accept(_ userName:String)
    func func_deny(_ userName:String)
    func func_i_will_think_about_it()
}



import UIKit
import KRProgressHUD

var pendingEventSelected:ScheduleEvents?

class You_ve_been_InvitedVC: UIViewController {
    @IBOutlet weak var txtWhy:UITextView!
    
    var delegate:Delegate_You_ve_been_Invited?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        funcGetMeetContent()
    }
    
    @IBAction func btnCancel(_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
    @IBAction func btn_accept(_ sender:UIButton) {
        func_update_event_status("1")
    }
    
    @IBAction func btn_deny(_ sender:UIButton) {
        func_update_event_status("2")
    }
    
    @IBAction func btn_i_will_think_about_it(_ sender:UIButton) {
        func_update_event_status("3")
    }
        
    func funcGetMeetContent() {
        if getMeetContent.count == 0 {
           let hud = KRProgressHUD.showOn(self)
           ViewControllerUtils.shared.showActivityIndicator()
           APIFunc.getAPI("get_meet_content", [:]) { (json,status,message)  in
               DispatchQueue.main.async {
                   ViewControllerUtils.shared.hideActivityIndicator()

                   let status = return_status(json.dictionaryObject!)
                   switch status {
                   case .success:
                       let decoder = JSONDecoder()
                       if let jsonData = json[result_resp].description.data(using: .utf8) {
                           do {
                                getMeetContent = try decoder.decode([GetMeetContent].self, from: jsonData)
                                self.txtWhy.text = getMeetContent[0].why.htmlToAttributedString?.string
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
        } else {
            self.txtWhy.text = getMeetContent[0].why.htmlToAttributedString?.string
        }
       
    }
        
    func func_update_event_status(_ statusEvent:String) {
        let param = [
            "meeting_id":pendingEventSelected!.meetingID!,
            "status":statusEvent
        ]
        print(param)
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("update_event_status",param) { (json,status,message) in
              DispatchQueue.main.async {
                  ViewControllerUtils.shared.hideActivityIndicator()

                  let status = return_status(json.dictionaryObject!)
                  switch status {
                  case .success:
                        
                        self.func_removeFromSuperview()
                        if statusEvent == "1" {
                            self.delegate?.func_accept(pendingEventSelected?.userName ?? "")
                        } else if statusEvent == "2" {
                            self.delegate?.func_deny(pendingEventSelected?.userName ?? "")
                        } else if statusEvent == "3" {
                            self.delegate?.func_i_will_think_about_it()
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
