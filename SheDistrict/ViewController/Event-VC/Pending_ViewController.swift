//  Pending_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/9/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import SDWebImage
import KRProgressHUD


class Pending_ViewController: UIViewController {
    @IBOutlet weak var tblPendingEvent:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(func_get_events), name: NSNotification.Name (rawValue: "sendInvitaion"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scheduleEvents.removeAll()
        func_get_events()
    }
    
    @objc func func_get_events() {
        let param = ["user_id":signUp!.userID]
        print(param)
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("get_events", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json["pending"].description.data(using: .utf8) {
                        do {
                            scheduleEvents = try decoder.decode([ScheduleEvents].self, from: jsonData)
                            scheduleEvents = scheduleEvents.reversed()
                            self.tblPendingEvent.reloadData()
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
    
}



extension Pending_ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! PendingEvent_TableCell
        
        if scheduleEvents.count > indexPath.row {
            let pendings = scheduleEvents[indexPath.row]
            cell.imgUserProfile.sd_setImage(with: URL(string:(pendings.userProfile ?? "").userProfile), placeholderImage:k_default_user)
                    
            let attrUserNameInvited = boldWithRange(pendings.text ?? "", pendings.friName ?? "", UIFont (name:"Roboto-Light", size:16.0)!, UIFont (name:"Roboto-Regular", size:16.0)!)
            
            cell.lblUserNameInvited.attributedText = attrUserNameInvited
            cell.lblTime.text = pendings.meetingTime
            
            if pendings.type!.lowercased() == "send" {
                cell.widthView.constant = 0
            } else {
                cell.widthView.constant = 50
            }
            
            cell.btnView.tag = indexPath.row
            cell.btnView.addTarget(self, action:#selector(btnView(_:)), for: .touchUpInside)
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = AnimationFactory.makeSlideIn(duration:0.25, delayFactor:0.01)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func btnView(_ sender:UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"YouveBeenInvited"), object: nil)
        pendingEventSelected = scheduleEvents[sender.tag]
    }
    
}


