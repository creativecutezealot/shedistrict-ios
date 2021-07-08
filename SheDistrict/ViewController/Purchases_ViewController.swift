//  Purchases_ViewController.swift
//  SheDistrict
//  Created by appentus on 1/17/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD
import StoreKit
import Alamofire

class Purchases_ViewController: UIViewController {
    
    @IBOutlet weak var collBoost:UICollectionView!
    
    @IBOutlet weak var viewLifeTime:UIView!
    @IBOutlet weak var viewNoLifeTime:UIView!
    @IBOutlet weak var btnOneSub: DesignableButton!
    @IBOutlet weak var btnTwoSub: DesignableButton!
    @IBOutlet weak var btnLifetimeSubs: DesignableButton!
    
    @IBOutlet var imgSelectedPlanSubscription: [UIImageView]!
    @IBOutlet weak var planTitleSubs: UILabel!
    @IBOutlet weak var titleLblSubscription: UILabel!
    @IBOutlet weak var titleLblLifetime: UILabel!
    @IBOutlet weak var titleAttributedLblLifetime: UILabel!
    @IBOutlet weak var currentPackageLbl: UILabel!
    
    let arrBoost = ["2","4","6","10"]
    var arrBoostsPrice = [String]()
    
    var arrProducts : [SKProduct] = []
    
    var subscriptionsOne: [SKProduct] = []
    var subscriptionsTwo: [SKProduct] = []
    var subscriptionsLifetime: SKProduct!
    var isSubscriptionOne = true
    var index = 0
    var subscriptionNamesWithproductId = [
        "lifetime":"Lifetime Subscription",
        "planonemonthone":"1 Month Subscription of Plan A",
        "planonemonthsix":"6 Month Subscription of Plan A",
        "planoneyearone":"1 Year Subscription of Plan A",
        "plantwomonthone":"1 Month Subscription of Plan B",
        "plantwomonthsix":"6 Month Subscription of Plan B",
        "plantwoyearone":"1 Year Subscription of Plan B"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collBoost.allowsSelection = true
        funcAddPurchasePopUp()
    }
    override func viewWillAppear(_ animated: Bool) {
        func_Check_IAP()
        for i in 0..<imgSelectedPlanSubscription.count{
            imgSelectedPlanSubscription[i].alpha = 0.0
        }
        let textLifetime = "<ul><li>Turn off read receipts</li><li>Unlimited boosts</li><li>Ads are removed</li><li>Two  week message limit removed</li><li>See everyone who has viewed your profile</li><li>Post an unlimited amount of announcements</li><li>personal invitations to exlusive events,meet ups, and more</li></ul>"
        self.titleLblLifetime.text = textLifetime.html2String
        
    }
    
    func funcAddPurchasePopUp() {
        viewLifeTime.frame = self.view.frame
        viewNoLifeTime.frame = self.view.frame
        
        self.view.addSubview(viewLifeTime)
        self.view.addSubview(viewNoLifeTime)
        
        viewLifeTime.isHidden = true
        viewNoLifeTime.isHidden = true
    }
    
    func funcShowPopUps(_ view:UIView) {
        view.transform = CGAffineTransform(scaleX:2, y:2)
        view.isHidden = false
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            view.transform = .identity
        })
    }
    
    func funcHidePopUps(_ view:UIView) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping:0.5, initialSpringVelocity: 0, options: [], animations: {
            view.transform = CGAffineTransform(scaleX:0.02, y: 0.02)
        }) { (success) in
            view.isHidden = true
        }
    }
    
    @IBAction func btnPrice1(_ sender:UIButton) {
        funcShowPopUps(viewNoLifeTime)
        setContent(isPlanOne: true)
        isSubscriptionOne = true
        setPriceOfPlan(index: 0)
        index = 0
        for i in 0..<imgSelectedPlanSubscription.count{
            imgSelectedPlanSubscription[i].alpha = 0.0
        }
        imgSelectedPlanSubscription[0].alpha = 1.0
    }
    
    @IBAction func btnPrice2(_ sender:UIButton) {
        funcShowPopUps(viewNoLifeTime)
        setContent(isPlanOne: false)
        isSubscriptionOne = false
        setPriceOfPlan(index: 0)
        index = 0
        for i in 0..<imgSelectedPlanSubscription.count{
            imgSelectedPlanSubscription[i].alpha = 0.0
        }
        imgSelectedPlanSubscription[0].alpha = 1.0
    }
    
    @IBAction func btnPrice3(_ sender:UIButton) {
        funcShowPopUps(viewLifeTime)
    }
    
    @IBAction func btnPurchase1(_ sender:UIButton) {
        funcHidePopUps(viewNoLifeTime)
        if isSubscriptionOne{
            purchaseOtherProducts(product: subscriptionsOne[index])
        }else{
            purchaseOtherProducts(product: subscriptionsTwo[index])
        }
    }
    
    @IBAction func btnPurchase2(_ sender:UIButton) {
        purchaseLifetime()
    }
    
    @IBAction func btnPurchaseCancel(_ sender:UIButton) {
        funcHidePopUps(viewLifeTime)
        funcHidePopUps(viewNoLifeTime)
    }
    @IBAction func popupViewMonthsAction(_ sender: UIButton) {
        setPriceOfPlan(index: sender.tag)
        for i in 0..<imgSelectedPlanSubscription.count{
            if i == sender.tag{
                UIView.animate(withDuration: 0.25) {
                    self.imgSelectedPlanSubscription[i].alpha = 1.0
                }
            }else{
                UIView.animate(withDuration: 0.25) {
                    self.imgSelectedPlanSubscription[i].alpha = 0.0
                }
            }
        }
    }
    
    
}

extension Purchases_ViewController{
    
    func daysFromSubPeriod(subscription : SKProduct)->Int{
        
        if #available(iOS 11.2, *) {
            let periodUnit = subscription.subscriptionPeriod!.numberOfUnits
            let periodTimeUnit = unitName(unitRawValue: subscription.subscriptionPeriod!.unit.rawValue)
            let totalDays = periodUnit*periodTimeUnit
            return totalDays
        } else {
            return 0
        }
    }
    func unitName(unitRawValue:UInt) -> Int {
        switch unitRawValue {
        case 0: return 1
        case 1: return 7
        case 2: return 30
        case 3: return 356
        default: return 0
        }
    }
    
}
extension Purchases_ViewController{
    func purchaseLifetime(){
        let hud = KRProgressHUD.showOn(self)
        
        ViewControllerUtils.shared.showActivityIndicator()
        PKIAPHandler.shared.purchase(product: subscriptionsLifetime) { (alert, product, transaction) in
            if product != nil{
                self.funcHidePopUps(self.viewLifeTime)
                self.purchaseBoostApi(planType: "plan", boosts: "", amount: product!.price, plan_id: "plan_3", validity: 0, currency: product!.priceLocale.currencySymbol!)
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                //                funcHidePopUps(viewLifeTime)
                hud.showError(withMessage: "Error Purchasing plan please try again")
            }
        }
    }
    func purchaseOtherProducts(product: SKProduct){
        let hud = KRProgressHUD.showOn(self)
        
        print(product.productIdentifier)
        ViewControllerUtils.shared.showActivityIndicator()
        PKIAPHandler.shared.purchase(product: product) { (alert, product, transaction) in
            if product != nil{
                self.funcHidePopUps(self.viewNoLifeTime)
                if self.isSubscriptionOne{
                    self.purchaseBoostApi(planType: "plan", boosts: "", amount: product!.price, plan_id: "plan_1", validity: self.daysFromSubPeriod(subscription: product!), currency: product!.priceLocale.currencySymbol!)
                }else{
                    self.purchaseBoostApi(planType: "plan", boosts: "", amount: product!.price, plan_id: "plan_2", validity: self.daysFromSubPeriod(subscription: product!), currency: product!.priceLocale.currencySymbol!)
                }
            }else{
                ViewControllerUtils.shared.hideActivityIndicator()
                hud.showError(withMessage: "Error Purchasing plan please try again")
            }
        }
    }
    
    func purchaseBoost(product:SKProduct){
        let hud = KRProgressHUD.showOn(self)
        
        ViewControllerUtils.shared.showActivityIndicator()
        PKIAPHandler.shared.purchase(product: product) { (alert, product, transaction) in
            
            let indexOfBoost = self.arrProducts.firstIndex(of: product!)!+1
            let boostsAllowed = (indexOfBoost<3) ? (2*indexOfBoost) :10
            
            if product != nil{
                self.purchaseBoostApi(planType: "product", boosts: "\(boostsAllowed)", amount: product!.price, plan_id: "", validity: 0, currency: product!.priceLocale.currencySymbol!)
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
}
extension Purchases_ViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collBoost.frame.height
        return CGSize (width:width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrBoostsPrice.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for:indexPath) as! PurchaseCVC
        cell.btnSelect.tag = indexPath.row
        cell.btnSelect.addTarget(self, action: #selector(self.selectBoost(_:)), for: .touchUpInside)
        cell.lblBoostCount.text = arrBoost[indexPath.row]
        cell.lblBoostPrice.text = arrBoostsPrice[indexPath.row]
        
        return cell
    }
    @objc func selectBoost(_ sender:UIButton){
        purchaseBoost(product: arrProducts[sender.tag])
    }
    
    func func_Check_IAP() {
        
        let hud = KRProgressHUD.showOn(self)
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
                
                sSelf.getSubGroupOne {
                    sSelf.getSubGroupTwo {
                        sSelf.getLifetimeSub {
                            
                            sSelf.collBoost.reloadData()
                            let myString:NSString = "For a one-time payment of \(sSelf.subscriptionsLifetime.priceLocale.currencySymbol!) \(sSelf.subscriptionsLifetime.price)" as NSString
                            var myMutableString = NSMutableAttributedString()
                            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Roboto-Regular", size: 14.0)!])
                            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: hexStringToUIColor("#62157B"), range: NSRange(location:25,length:myString.length-25))
                            sSelf.titleAttributedLblLifetime.attributedText = myMutableString
                            sSelf.checkAcitveSubscription { (resp, data,dateExp) in
                                ViewControllerUtils.shared.hideActivityIndicator()
                                if resp{
                                    if let receiptInfo: NSArray = data!["latest_receipt_info"] as? NSArray {
                                        
                                        let df = DateFormatter.init(format: "dd/MM/yyyy")
                                        let lastReceipt = receiptInfo.lastObject as! NSDictionary
                                        let productId = "\(lastReceipt["product_id"]!)"
                                        let dateInStr = dateExp != nil ? "\(df.string(from: dateExp!))" : ""
                                        sSelf.currentPackageLbl.text = sSelf.subscriptionNamesWithproductId[productId]! + (productId == "lifetime" ? "" :  " - Renews on \(dateInStr)")
                                        
                                    }
                                }else{
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getSubGroupOne(completion:@escaping()->()) {
        let productId = ["planonemonthone","planonemonthsix","planoneyearone"]
        PKIAPHandler.shared.setProductIds(ids: productId)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard let sSelf = self else { return}
            DispatchQueue.main.async {
                sSelf.subscriptionsOne = products
                sSelf.btnOneSub.setTitle("\(sSelf.subscriptionsOne[0].priceLocale.currencySymbol ?? "") \(sSelf.subscriptionsOne[0].price)", for: .normal)
                
                completion()
            }
        }
        
    }
    
    func getSubGroupTwo(completion:@escaping()->()) {
        let productId = ["plantwomonthone","plantwomonthsix","plantwoyearone"]
        PKIAPHandler.shared.setProductIds(ids: productId)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard let sSelf = self else { return}
            DispatchQueue.main.async {
                sSelf.subscriptionsTwo = products
                sSelf.btnTwoSub.setTitle("\(sSelf.subscriptionsTwo[0].priceLocale.currencySymbol ?? "") \(sSelf.subscriptionsTwo[0].price)", for: .normal)
                completion()
            }
        }
    }
    
    func getLifetimeSub(completion:@escaping()->()) {
        let productId = ["lifetime"]
        PKIAPHandler.shared.setProductIds(ids: productId)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard let sSelf = self else { return}
            DispatchQueue.main.async {
                sSelf.subscriptionsLifetime = products[0]
                sSelf.btnLifetimeSubs.setTitle("\(sSelf.subscriptionsLifetime.priceLocale.currencySymbol ?? "") \(sSelf.subscriptionsLifetime.price)", for: .normal)
                completion()
            }
        }
    }
    
    func setContent(isPlanOne:Bool){
        let textForPlanOne = "<ul><li>Turn off read receipts</li><li>Ads are removed</li><li>Two week message limit removed</li><li>See up to 10 of your most recent viewers</li><li>Post up to 6 announcements</li><li>Two free boosts </li><li>Ads are removed</li><li>See up to 10 of your most recent viewers </li><li>Post up to 6 announcements</li></ul>"
        let textForPlanTwo = "<ul><li>Turn off read receipts</li><li>Two free boosts</li><li>Ads are removed</li><li>Two week message limit removed</li><li>See up to 20 of your most recent viewers</li><li>Post up to 10 announcements</li><li>Hide location </li><li>Hide age</li></ul>"
        
        titleLblSubscription.text = isPlanOne ? textForPlanOne.html2String : textForPlanTwo.html2String
        
    }
    func setPriceOfPlan(index:Int){
        self.index = index
        if isSubscriptionOne{
            planTitleSubs.text =  "For \(subscriptionsOne[index].priceLocale.currencySymbol!) \(subscriptionsOne[index].price)"
            
        }else{
            planTitleSubs.text = "For \(subscriptionsTwo[index].priceLocale.currencySymbol!) \(subscriptionsTwo[index].price)"
            
        }
        
    }
    
    func checkAcitveSubscription(completion:@escaping(Bool,NSDictionary?,Date?)->()){
        let receiptURL = Bundle.main.appStoreReceiptURL
        guard let receipt = NSData(contentsOf: receiptURL!)else{
            completion(false,nil, nil)
            return
        }
        let requestContents: [String: Any] = [
            "receipt-data": receipt.base64EncodedString(options: []),
            "password": "8cb089dcd48540eebf820042a2e60c44"
        ]
        
        let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
        
        let stringURL = "https://\(appleServer).itunes.apple.com/verifyReceipt"
        
        print("Loading user receipt: \(stringURL)...")
        
        Alamofire.request(stringURL, method: .post, parameters: requestContents, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let value = response.result.value as? NSDictionary {
                    if let dateExp = self.expirationDateFromResponse(jsonResponse: value) {
                        print(dateExp)
                        completion(true,value,dateExp)
                    }else{
                        completion(true,value,nil)
                    }
                } else {
                    print("Receiving receipt from App Store failed: \(response.result)")
                    completion(false,nil,nil)
                }
        }
    }
    func expirationDateFromResponse(jsonResponse: NSDictionary) -> Date? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            let expirationDate: Date =
                formatter.date(from: lastReceipt["expires_date"] as! String)!
            
            return expirationDate
            
        } else {
            
            return nil
            
        }
    }
}


extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}
extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
