//  Preferences_TableViewCell.swift
//  SheDistrict
//  Created by appentus on 1/8/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit


class Preferences_TableViewCell: UITableViewCell {
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



extension Preferences_TableViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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
        titlesArr!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell-preftype", for: indexPath) as! PrefCollectionViewCell
        
        cell.btnSelect.isSelected = selectedBoolArr[indexPath.row]
        cell.btnSelect.tag = indexPath.row
        cell.lblPreDetails.text = titlesArr![indexPath.row].valueName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if preference[collPref.tag].inputType == "radio" {
            for i in 0..<selectedBoolArr.count {
                if i == indexPath.row {
                    selectedBoolArr[i] = true
                } else {
                    selectedBoolArr[i] = false
                }
            }
        } else {
            self.selectedBoolArr[indexPath.row] = (self.selectedBoolArr[indexPath.row] == true) ? false : true
        }
        NotificationCenter.default.post(name: NSNotification.Name("c"), object: self.selectedBoolArr,userInfo: ["tag": collPref.tag])
        self.collPref.reloadData()
    }
    
}


