//  New_Post_VC.swift
//  SheDistrict
//  Created by appentus on 1/7/20.
//  Copyright © 2020 appentus. All rights reserved.



import UIKit
import AVKit
import KRProgressHUD
import SDWebImage


class New_Post_VC: UIViewController ,UITextFieldDelegate{
    var searchTimer: Timer?

    @IBOutlet weak var view_camera:UIView!
    @IBOutlet weak var img_selected:UIImageView!
    
    @IBOutlet weak var viewGalerry:UIView!
    @IBOutlet weak var imgSelectedGalery:UIImageView!
    
    @IBOutlet weak var txt_choose_category:UITextField!
    @IBOutlet weak var txt_title:UITextField!
    @IBOutlet weak var txt_description:UITextView!
    
    @IBOutlet var view_post:[UIView]!
    
    @IBOutlet weak var viewSheDistrictGallery:UIView!
    
    let drop_down = DropDown()
    
    var k_Description = "Description"
    
    var is_repost = false
    
    var imagePicker = UIImagePickerController()
    
//    SheDistrict Galery popup
    var arrSelectedGaleryPopup = [Bool]()
    @IBOutlet weak var collSheDistrictGalery:UICollectionView!
    @IBOutlet weak var txtSearch:UITextField!
    @IBOutlet weak var btnCancelSearch:UIButton!
    
    var arrUnSplash = [[String:Any]]()
    
    var page = 1
    var image_type = "1"
    var toSearchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt_choose_category.returnKeyType = .done
        txt_description.returnKeyType = .done
        
        img_selected.layer.cornerRadius = 10
        img_selected.clipsToBounds = true
        
        if is_repost {
            func_repost()
        }
        
        func_post_category_API()
        funcSelectedGaleryPopUp()
    }
    
    @IBAction func btn_upload_photo(_ sender:UIButton) {
        func_ChooseImage()
    }
    
    @IBAction func btn_preview(_ sender:UIButton) {
        if !func_validation() {
            return
        }
        
        let storyboard = UIStoryboard (name: "Main_1", bundle: nil)
        let preview_announcement = storyboard.instantiateViewController(withIdentifier: "Preview_Announcement_VC") as! Preview_Announcement_VC
        var imgParam = UIImage()
        if image_type == "1" {
            imgParam = img_selected.image!
        } else {
            imgParam = imgSelectedGalery.image!
        }
        
        preview_announcement.arr_annoucement = [txt_title.text!,txt_choose_category.tag,imgParam,txt_description.text!]
        self.navigationController?.pushViewController(preview_announcement, animated:true)
    }
    
    private func func_validation() -> Bool {
        var is_valid = false
        if !view_camera.isHidden && !viewGalerry.isHidden {
            view_post[0].shake()
            view_post[0].func_error_shadow()
            is_valid = false
        } else if txt_choose_category.text!.isEmpty {
            view_post[1].shake()
            view_post[1].func_error_shadow()
            is_valid = false
        } else if txt_title.text!.isEmpty {
            view_post[2].shake()
            view_post[3].func_error_shadow()
            is_valid = false
        } else if txt_description.text!.isEmpty {
            view_post[2].shake()
            view_post[2].func_error_shadow()
            is_valid = false
        } else if txt_description.text! == k_Description {
            view_post[3].shake()
            view_post[3].func_error_shadow()
            is_valid = false
        } else {
            is_valid = true
        }
        
        return is_valid
    }
    
    func func_post_category_API() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.getAPI("post_category", [:]) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            postcategory = try decoder.decode([Postcategory].self, from: jsonData)
                            self.func_drop_down()
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
    
    func func_repost() {
        view_camera.isHidden = true
        img_selected.sd_setImage(with: URL(string:k_Base_URL_Imgae+get_details!.announcementImage), placeholderImage:nil)
        txt_choose_category.text = get_details?.category[0].categoryName
        txt_choose_category.tag = Int((get_details?.category[0].categoryID)!)!-1
        txt_title.text = get_details?.announcementTitle
        txt_description.text = get_details?.announcementDesc
        
        txt_description.textColor = UIColor .black
    }
    
    @IBAction func btn_submit(_ sender:UIButton) {
        self.view.endEditing(true)
        
        if !func_validation() {
            return
        }
        
        let param = [
            "user_id":signUp!.userID,
            "category_id":postcategory[txt_choose_category.tag].categoryID,
            "announcement_title":txt_title.text!,
            "announcement_desc":txt_description.text!,
            "image_type":"1"
            ] as [String:String]
        print(param)
        
        var imgParam = UIImage()
        if image_type == "1" {
            imgParam = img_selected.image!
        } else {
            imgParam = imgSelectedGalery.image!
        }
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        APIFunc.postAPI_Image("add_announcement",imgParam.jpegData(compressionQuality: 0.2), param, "image") { (json, status, message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                if status == success_resp {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        self.btn_Deleted_Message()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        hud.showError(withMessage: message)
                    }
                }
            }
        }
        
    }
    
}

extension New_Post_VC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func func_camera_permission(completion:@escaping (Bool)->()) {
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
    
    func func_ChooseImage() {
        for view in view_post {
            view.func_success_shadow()
        }
        
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
    
    func func_OpenCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = false
            imagePicker.delegate=self
            
            func_camera_permission { (is_permission) in
                if is_permission {
                    DispatchQueue.main.async {
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert  = UIAlertController(title: "Warning!", message: "You don't have camera in simulator", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func func_OpenGallary() {
        imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.allowsEditing = false
        imagePicker.delegate=self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            image_type = "1"
            
            img_selected.isHidden = false
            img_selected.image = pickedImage
            view_camera.isHidden = true
            
            viewGalerry.isHidden = false
            imgSelectedGalery.isHidden = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}



import DropDown
extension New_Post_VC {
    func func_drop_down() {
        self.view.endEditing(true)
        
        var arr_category_name = [String]()
        
        for category in postcategory {
            arr_category_name.append(category.categoryName)
        }
        
        drop_down.dismissMode = .manual
        drop_down.backgroundColor = UIColor.white
        
        drop_down.anchorView = txt_choose_category
        drop_down.bottomOffset = CGPoint(x: 0, y:txt_choose_category.bounds.height)
        drop_down.dataSource = arr_category_name
        
        drop_down.selectionAction = { [weak self] (index, item) in
            self?.txt_choose_category.tag = index
            self?.txt_choose_category.text = item
        }
    }
}


extension New_Post_VC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        for view in view_post {
            view.func_success_shadow()
        }
        
        if textField == txt_choose_category  {
            drop_down.show()
            return false
        } else if textField == txtSearch {
            btnCancelSearch.isHidden = false
            return true
        } else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if txt_title == textField {
            if txt_title.text!.count < 40 {
                return true
            } else {
                if string == "" {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return true
        }
    }
    
}


extension New_Post_VC:UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        for view in view_post {
            view.func_success_shadow()
        }
        
        if textView.text == k_Description {
            textView.textColor = UIColor .black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = hexStringToUIColor("AEAEAE")
            textView.text = k_Description
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if txt_description == textView {
            if txt_description.text!.count < 100 {
                return true
            } else {
                if text == "" {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return true
        }
    }
    
}

//MARK:- ShedistrictGaleray
extension New_Post_VC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBAction func txtSearchUnsplash(_ sender: UITextField) {
        if sender.text!.trimmingCharacters(in: .whitespaces).count == 0{
            btnCancelSearch.isHidden = true
        }else{
            btnCancelSearch.isHidden = false
        }
    }
    
    func funcSelectedGaleryPopUp() {
        btnCancelSearch.isHidden = true
        viewSheDistrictGallery.frame = self.view.frame
        self.view.addSubview(viewSheDistrictGallery)
        viewSheDistrictGallery.isHidden = true
        
        arrUnSplash = [[String:Any]]()
        self.arrSelectedGaleryPopup = [Bool]()
        self.txtSearch.delegate = self

        // handle the editingChanged event by calling (textFieldDidEditingChanged(-:))
        self.txtSearch.addTarget(self, action: #selector(textFieldDidEditingChanged(_:)), for: .editingChanged)

    }
    // reset the searchTimer whenever the textField is editingChanged
      @objc func textFieldDidEditingChanged(_ textField: UITextField) {

          // if a timer is already active, prevent it from firing
          if searchTimer != nil {
              searchTimer?.invalidate()
              searchTimer = nil
          }

          // reschedule the search: in 1.0 second, call the searchForKeyword method on the new textfield content
          searchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(searchForKeyword(_:)), userInfo: textField.text!, repeats: false)
      }

      @objc func searchForKeyword(_ timer: Timer) {
        // retrieve the keyword from user info
        let keyword = timer.userInfo as! String

        print("Searching for keyword \(keyword)")

        arrSelectedGaleryPopup.removeAll()
        arrUnSplash.removeAll()
        collSheDistrictGalery.reloadData()
        toSearchText = keyword
        page = 1
        if keyword.trimmingCharacters(in: .whitespaces) == "" {
            funcUnSplashFullImages()
        } else {
            funcUnSplashFullImagesSearch(keyword)
        }
      }
    
    @IBAction func btnCancelSearch(_ sender:UIButton) {
        btnCancelSearch.isHidden = true
        txtSearch.text = ""
    }
    
    @IBAction func btnSheDistrictGallery(_ sender:UIButton) {
        for view in view_post {
            view.func_success_shadow()
        }
        
        funcUnSplashFullImages()
        
        self.viewSheDistrictGallery.transform = CGAffineTransform(scaleX:2, y:2)
        self.viewSheDistrictGallery.isHidden = false
        UIView.animate(withDuration:0.2, delay: 0, usingSpringWithDamping:0.7, initialSpringVelocity: 0, options: [],  animations: {
            self.viewSheDistrictGallery.transform = .identity
        })
    }
    
    @IBAction func btnCancelSheDistrictGallery(_ sender:UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping:0.5, initialSpringVelocity: 0, options: [], animations: {
            self.viewSheDistrictGallery.transform = CGAffineTransform(scaleX:0.02, y: 0.02)
        }) { (success) in
            self.viewSheDistrictGallery.isHidden = true
        }
    }
    
    func btn_Deleted_Message() {
        self.funcDeletedMessage("Your announcement", "has been ", "posted!")
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width:collSheDistrictGalery.frame.width, height:44.0)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        collectionView.register(UINib.init(nibName: "FooterRefresh", bundle: nil), forCellWithReuseIdentifier: "cellFooter")
//
//        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:"cellFooter", for: indexPath)
//        footerView.backgroundColor = UIColor.green
//
//        let refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        refreshControl.backgroundColor = UIColor.red
//        refreshControl.tintColor = UIColor.blue
//
//        refreshControl.addTarget(self, action: #selector(funcUnSplashFullImages), for: .valueChanged)
//        footerView.addSubview(refreshControl)
//
////        footerView.configure(with: data[indexPath.row])
//
//        return footerView
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUnSplash.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/2-7
        return CGSize (width:width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for:indexPath) as! SheDistrictCVC
        
        cell.viewContainer.layer.borderColor = arrSelectedGaleryPopup[indexPath.row] ? hexStringToUIColor("FFD200").cgColor : UIColor .white.cgColor
        cell.viewContainer.layer.borderWidth = arrSelectedGaleryPopup[indexPath.row] ? 4 : 0
        
        if let dictURLs = arrUnSplash[indexPath.row]["urls"] as? [String:String] {
            let small = dictURLs["regular"]!
            cell.imgPhotos.sd_setImage(with: URL(string:small), placeholderImage:k_default_user)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<self.arrUnSplash.count {
            if i == indexPath.row {
                arrSelectedGaleryPopup[i] = true
            } else {
                arrSelectedGaleryPopup[i] = false
            }
        }
        image_type = "2"
        
        img_selected.isHidden = true
        view_camera.isHidden = false
        
        viewGalerry.isHidden = true
        imgSelectedGalery.isHidden = false
        
        if let dictURLs = arrUnSplash[indexPath.row]["urls"] as? [String:String] {
            let small = dictURLs["regular"]!
            imgSelectedGalery.sd_setImage(with: URL(string:small), placeholderImage:k_default_user)
        }
        
        collSheDistrictGalery.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == arrUnSplash.count - 1 {
            page += 1
            if toSearchText == "" {
                funcUnSplashFullImages()
            } else {
                funcUnSplashFullImagesSearch(toSearchText)
            }
        }
    }
    
    @objc func funcUnSplashFullImages() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        toSearchText = ""
        APIFunc.getAPIUnSplash("https://api.unsplash.com/photos?page=\(page)",[:]) { (arrUnsplashAllImages) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                                
                for i in 0..<arrUnsplashAllImages.count {
                    self.arrSelectedGaleryPopup.append(false)
                    self.arrUnSplash.append(arrUnsplashAllImages[i])
                }
                self.collSheDistrictGalery.reloadData()
                if self.page == 1{

                    if self.arrSelectedGaleryPopup.count > 0{
                                    self.collSheDistrictGalery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                                }
                    
                }
            }
        }
    }
    
    @objc func funcUnSplashFullImagesSearch(_ text:String) {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator(); APIFunc.getAPIUnSplashSearch("https://api.unsplash.com/search/photos?page=\(page)&query=\(text)",[:]) { (arrUnsplashAllImages) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                    
                for i in 0..<arrUnsplashAllImages.count {
                    let dictResp = arrUnsplashAllImages[i] as! NSDictionary
                    let urlDict = dictResp["urls"] as! NSDictionary
                    let imgUrl = urlDict["regular"] as! String
                    self.arrSelectedGaleryPopup.append(false)
                    self.arrUnSplash.append(dictResp as! [String : Any])
                }
                self.collSheDistrictGalery.reloadData()

                if self.page == 1{

                    if self.arrSelectedGaleryPopup.count > 0{
                                    self.collSheDistrictGalery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                                }
                    
                }
            }
        }
    }
    
}

