//  Search_TableViewCell.swift
//  SheDistrict
//  Created by appentus on 1/8/20.
//  Copyright © 2020 appentus. All rights reserved.

import UIKit

class Search_TableViewCell: UITableViewCell {
    @IBOutlet weak var lbl_title:UILabel!
    @IBOutlet weak var coll_search:UICollectionView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        coll_search.delegate = self
        coll_search.dataSource = self
    }
    
}

extension Search_TableViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:80, height:80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userAccordingPreference.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Search_CollectionCell
        
        if userAccordingPreference.count > indexPath.row {
            let userProfile = userAccordingPreference[indexPath.row].userProfile.userProfile
            cell.img_user.sd_setImage(with: URL(string:userProfile), placeholderImage:k_default_user)
        } else {
            cell.img_user.image = k_default_user
        }
        
        cell.btnSelectCollCell.tag = indexPath.row
        cell.btnSelectCollCell.addTarget(self, action:#selector(btnSelectCollCell(_:)), for: .touchUpInside)
                
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"selectPref"), object:coll_search.tag)
    }
    
    @IBAction func btnSelectCollCell(_ sender:UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue:"selectCollCell"), object:sender)
    }
    
}

