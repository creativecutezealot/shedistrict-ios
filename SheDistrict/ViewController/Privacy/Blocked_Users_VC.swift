//
//  Blocked_Users_VC.swift
//  SheDistrict
//
//  Created by appentus on 1/16/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import UIKit
import KRProgressHUD


class Blocked_Users_VC: UIViewController {
    @IBOutlet weak var tblBlockUsers:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBlockUser.removeAll()
        func_API_get_block_user()
    }
    
    func func_API_get_block_user() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let param = ["user_id":signUp!.userID]
        APIFunc.postAPI("get_block_user", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json["result_array"].description.data(using: .utf8) {
                        do {
                            getBlockUser = try decoder.decode([GetBlockUser].self, from: jsonData)
                            self.tblBlockUsers.reloadData()
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



extension Blocked_Users_VC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getBlockUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! BlockUsersTableCell
        
        let getBlockUsers = getBlockUser[indexPath.row]
        
        cell.imgProfileUsers.sd_setImage(with: URL(string:(getBlockUsers.userProfile ?? "").userProfile), placeholderImage:k_default_user)
        cell.lblUserName.text = getBlockUsers.userName
        cell.lblBlockedOn.text = "Blocked on "+(getBlockUsers.created ?? "").timeFormatMMDDYYYY
        
        cell.btnUnBlock.tag = indexPath.row
        cell.btnUnBlock.addTarget(self, action:#selector(btnUnBlock(_:)), for:.touchUpInside)
        
        return cell
    }
    
    @IBAction func btnUnBlock(_ sender:UIButton) {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()

        let param = [
            "user_id":signUp!.userID,
            "block_user_id":getBlockUser[sender.tag].userID ?? ""
        ]
        APIFunc.postAPI("user_unblock", param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    hud.showSuccess(withMessage: message)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        self.func_API_get_block_user()
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
    
}
