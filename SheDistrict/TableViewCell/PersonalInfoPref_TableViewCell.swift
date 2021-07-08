//  ViewController.swift
//  SheDistrict
//  Created by appentus on 3/19/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import KRProgressHUD


class PersonalInfoPref_TableViewCell: UITableViewCell {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var lbl_preference_name:UILabel!
    @IBOutlet weak var btnSelect:UIButton!
    @IBOutlet weak var btnUpDown:UIButton!
    
    @IBOutlet weak var collPref:UICollectionView!
    @IBOutlet weak var topCollPref:NSLayoutConstraint!
    
    @IBOutlet weak var heightCollPref:NSLayoutConstraint!
    
    @IBOutlet weak var lblInfoValue:UILabel!
    
    var numberOfItem = 10
    var selectedBoolArr = [Bool]()
    var titlesArr:[Preference_Value]?
    var valueInterest: [ValueInterest]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        collPref.delegate = self
        collPref.dataSource = self
    }
    
}



extension PersonalInfoPref_TableViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collPref.frame.width/2 - 32
        return CGSize (width:width, height:30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if is_interests {
            return valueInterest!.count
        } else {
            return titlesArr!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if is_interests {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell-preftype", for: indexPath) as! PrefCollectionViewCell
            
            cell.btnSelect.isSelected = selectedBoolArr[indexPath.row]
            cell.btnSelect.tag = indexPath.row
            cell.lblPreDetails.text = valueInterest![indexPath.row].interestValue
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell-preftype", for: indexPath) as! PrefCollectionViewCell
            
            cell.btnSelect.isSelected = selectedBoolArr[indexPath.row]
            cell.btnSelect.tag = indexPath.row
            cell.lblPreDetails.text = titlesArr![indexPath.row].valueName
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if is_interests {
            arrInterestInfoValue[collPref.tag] = valueInterest![indexPath.row].interestValue
                //valueInterest![indexPath.row].interest
            print(arrInterestInfoValue)
            
            for i in 0..<selectedBoolArr.count {
                if i == indexPath.row {
                    selectedBoolArr[i] = true
                } else {
                    selectedBoolArr[i] = false
                }
            }
            
            funcUpdate_user_profile()
            NotificationCenter.default.post(name: NSNotification.Name("updateSelectArr"), object: self.selectedBoolArr,userInfo: ["tag": collPref.tag])
            self.collPref.reloadData()
        } else {
            arrPersonalInfoValue[collPref.tag] = titlesArr![indexPath.row].valueName
            print(arrPersonalInfoValue)
            
            for i in 0..<selectedBoolArr.count {
                if i == indexPath.row {
                    selectedBoolArr[i] = true
                } else {
                    selectedBoolArr[i] = false
                }
            }
            
            funcUpdate_user_profile()
            NotificationCenter.default.post(name: NSNotification.Name("updateSelectArr"), object: self.selectedBoolArr,userInfo: ["tag": collPref.tag])
            self.collPref.reloadData()
        }
    }
    
    func funcUpdate_user_profile() {
        var dictPersonalInfoUpdate = [String:String]()
        
        for i in 0..<preference.count {
            let keyPersonalInfo = preference[i].preference.replacingOccurrences(of:" ", with:"_")
            dictPersonalInfoUpdate[keyPersonalInfo] = arrPersonalInfoValue[i]
        }
        print(dictPersonalInfoUpdate)
        
        var dictInterestInfoUpdate = [String:String]()
        
        for i in 0..<getInterest.count {
            let keyPersonalInfo = getInterest[i].interest.replacingOccurrences(of:" ", with:"_")
            dictInterestInfoUpdate[keyPersonalInfo] = arrInterestInfoValue[i]
        }
        print(dictInterestInfoUpdate)
        
        let param = [
                "about_me":"",
                "friend_like":"",
                "describe_me":"",
                "hobbies":"",
                "personal_info":dictPersonalInfoUpdate.json,
                "interest_info":dictInterestInfoUpdate.json,
                "user_id":signUp!.userID
        ]
        print(param)
        
        APIFunc.postAPI("update_user_profile", param) { (json,status,message)  in
            DispatchQueue.main.async {
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    if signUp!.saveSignUp(json) {
                        print("saved")
                    }
                case .fail:
                    break
                case .error_from_api:
                    break
                }
                
            }
        }
    }
    
    
}


