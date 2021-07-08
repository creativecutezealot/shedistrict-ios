//  BoostsViewController.swift
//  SheDistrict
//  Created by iOS-Appentus on 31/March/2020.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import StoreKit
import SwiftyJSON

class BoostsViewController: UIViewController {
    
    @IBOutlet weak var collBoost:UICollectionView!
    
    @IBOutlet weak var userBoostedView: UIView!
    @IBOutlet weak var coolViewBoostedUsers: UICollectionView!
    @IBOutlet weak var boostedOrNotTitleLbl: UILabel!
    @IBOutlet weak var boostAgainBtn: DesignableButton!
    
    let arrBoost = ["2","4","6","10"]
    var arrBoostsPrice = [String]()
    var arrProducts : [SKProduct] = []
    
    var boostedUsers : [[String:Any]] = []
    
    var timer = Timer()
    var timerSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        get_all_product()
        userBoostedView.alpha = 0.0
    }
    
    @IBAction func boostAgain(_ sender: DesignableButton) {
        boostActivateAgain()
    }
    
}

extension BoostsViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collBoost{
            
            let width = collBoost.frame.height
            return CGSize (width:width, height:width)
        }else{
            let width = (collectionView.bounds.width - 32)/5
            return CGSize (width:width, height:width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collBoost{
            return arrBoostsPrice.count
        }else{
            return self.boostedUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collBoost{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for:indexPath) as! PurchaseCVC
            
            cell.lblBoostCount.text = arrBoost[indexPath.row]
            cell.lblBoostPrice.text = arrBoostsPrice[indexPath.row]
            cell.btnSelect.tag = indexPath.row
            cell.btnSelect.addTarget(self, action: #selector(self.purchaseBoostBtn(_:)), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"UserProfileViewsCollectionViewCell", for: indexPath) as! UserProfileViewsCollectionViewCell
            let current = boostedUsers[indexPath.row]
            cell.isBoosted(true)
            cell.img_user.sd_setImage(with: URL(string: fixEmptySpaceForUrl(stringCurrent: k_Base_URL_Imgae+(current["user_profile"] as! String))), placeholderImage:k_default_user)
            cell.btnSelectCollCell.tag = indexPath.row
            cell.btnSelectCollCell.addTarget(self, action:#selector(btnSelectCollCell(_:)), for: .touchUpInside)
            
            
            return cell
        }
        
        
    }
    @objc func btnSelectCollCell(_ sender:UIButton) {
        let storyboard = UIStoryboard (name:"Main_2", bundle:nil)
        let profileDetailsVC = storyboard.instantiateViewController(withIdentifier:"Profile_Details_ViewController") as! Profile_Details_ViewController
        profileDetailsVC.user_idFriend = boostedUsers[sender.tag]["user_id"] as! String
        self.navigationController?.pushViewController(profileDetailsVC, animated: true)
    }
    @objc func purchaseBoostBtn(_ sender:UIButton){
        purchaseBoost(product: arrProducts[sender.tag])
    }
    
    func purchaseBoost(product:SKProduct){
        let hud = KRProgressHUD.showOn(self)
        
        ViewControllerUtils.shared.showActivityIndicator()
        PKIAPHandler.shared.purchase(product: product) { (alert, product, transaction) in
            
            let indexOfBoost = self.arrProducts.firstIndex(of: product!)!+1
            let boostsAllowed = (indexOfBoost<3) ? (2*indexOfBoost) :10
            
            if product != nil{
                self.purchaseBoostApi(planType: "product", boosts: "\(boostsAllowed)", amount: product!.price, plan_id: "", validity: 0, currency: product!.priceLocale.currencySymbol!)
                ViewControllerUtils.shared.hideActivityIndicator()
                self.timer.invalidate()
                self.checkBoostedAndGetBoostResults()
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                //                funcHidePopUps(viewLifeTime)
                hud.showError(withMessage: "Error Purchasing plan please try again")
            }
        }
    }
    
    func purchaseBoostApi(planType:String,boosts:String,amount:NSDecimalNumber,plan_id:String,validity:Int,currency:String){
        let hud = KRProgressHUD.showOn(self)
        let param = [
            "user_id":signUp!.userID,
            "plan_type":planType,
            "boosts":boosts,
            "amount":amount,
            "plan_id":plan_id,
            "validity":validity,
            "currency":currency
            ] as [String:Any]
        
        APIFunc.postAPI("purchase_plan", param) { (jsonData, status, msg) in
            if status == "success"{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showSuccess(withMessage: msg)
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showError(withMessage: msg)
            }
        }
    }
    
    func boostActivateAgain(){
        ViewControllerUtils.shared.showActivityIndicator()
        
        let hud = KRProgressHUD.showOn(self)
        let param = [
            "user_id":signUp!.userID,
            ] as [String:Any]
        
        APIFunc.postAPI("boosts_again", param) { (jsonData, status, msg) in
            if status == "success"{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showSuccess(withMessage: msg)
                self.checkBoostedAndGetBoostResults()
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showError(withMessage: msg)
            }
        }
    }
}

extension BoostsViewController{
    
    func checkBoostedAndGetBoostResults(){
        timer.invalidate()
        boostedUsers = []
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI("boosts_users", ["user_id":signUp!.userID]) { (respData, status, message) in
            if status == "success"{
                let currentActiveBoost = "\(respData.dictionary!["current_boosts"]!)"
                let remainingBoost = Int("\(respData.dictionary!["boost_remaining"]!)")!
                self.userBoostedView.alpha = currentActiveBoost == "0" ? 0.0 : 1.0
                
                if (remainingBoost > 0) {
                    self.userBoostedView.alpha = 1.0
                    if currentActiveBoost == "0"{
                        self.coolViewBoostedUsers.alpha = 0.0
                        self.boostedOrNotTitleLbl.text = "You haven't boosted yet!"
                        self.boostAgainBtn.alpha = 1.0
                    }else{
                        self.coolViewBoostedUsers.alpha = 1.0
                        self.boostedOrNotTitleLbl.text = "You have been boosted for :- 5:00"
                        self.boostAgainBtn.alpha = 0.0
                        self.setupViews(respData: respData)
                    }
                    
                }else{
                    if currentActiveBoost == "0"{
                        self.coolViewBoostedUsers.alpha = 0.0
                        self.boostedOrNotTitleLbl.text = "You haven't boosted yet!"
                        self.boostAgainBtn.alpha = 0.0
                    }else{
                        self.coolViewBoostedUsers.alpha = 1.0
                        self.boostedOrNotTitleLbl.text = "You have been boosted for :- 5:00"
                        self.boostAgainBtn.alpha = 0.0
                        self.setupViews(respData: respData)
                    }
                }
                
                
                ViewControllerUtils.shared.hideActivityIndicator()
                
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showError(withMessage: message)
            }
        }
    }
    
    func setupViews(respData:JSON){
        let resultArr = respData.dictionary!["result"]!.array!
        var myUserData = [String:Any]()
        
        for i in 0..<resultArr.count{
            let dicr = resultArr[i]
            self.boostedUsers.append(dicr.dictionaryObject!)
            let userid = "\(dicr.dictionaryObject!["user_id"]!)"
            if userid == signUp!.userID{
                myUserData = dicr.dictionaryObject!
            }
        }
        
        let timeLast = Int("\(myUserData["boosts_active_time"]!)")!
        let timeExpire = 300000+timeLast
        let currentTimeInMiliSec = Int(Date().timeIntervalSince1970 * 1000)
        self.coolViewBoostedUsers.reloadData()
        
        if currentTimeInMiliSec > timeExpire{
            //                    boost expired
            //                    self.
        }else{
            //                    start timer
            let secondsLeft = Int(Float(timeExpire - currentTimeInMiliSec)/1000)
            
            self.timerSeconds = secondsLeft
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer(_:)), userInfo: nil, repeats: true)
            self.timer.fire()
        }
    }
    
    @objc func updateTimer(_ timer:Timer){
        if self.timerSeconds == 0{
            timer.invalidate()
            checkBoostedAndGetBoostResults()
        }else{
            self.timerSeconds -= 1
            self.boostedOrNotTitleLbl.text = "You have been boosted for :- \(secondsToHoursMinutesSeconds(seconds: self.timerSeconds))"
        }
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        return "\((seconds % 3600) / 60) : \((seconds % 3600) % 60)"
    }
    
    //    MARK:- get boost plans
    
    func get_all_product() {
        self.arrProducts = [SKProduct]()
        self.func_Check_IAP()
    }
    
    func func_Check_IAP() {
        
        ViewControllerUtils.shared.showActivityIndicator()
        PKIAPHandler.shared.setProductIds(ids: ["Boost1","Boost2","Boost3","Boost4"])
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard let sSelf = self else {return}
            DispatchQueue.main.async {
                
                sSelf.arrBoostsPrice = []
                sSelf.arrProducts = []
                
                for i in 0..<products.count{
                    let prodNow = products[i]
                    sSelf.arrBoostsPrice.append("\(prodNow.priceLocale.currencySymbol ?? "") \(prodNow.price)")
                    sSelf.arrProducts.append(products[i])
                }
                
                ViewControllerUtils.shared.hideActivityIndicator()
                sSelf.collBoost.reloadData()
                sSelf.checkBoostedAndGetBoostResults()
                
            }
        }
    }
}
