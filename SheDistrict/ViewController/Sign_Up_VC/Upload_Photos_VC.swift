//  Upload_Photos_VC.swift
//  SheDistrict
//  Created by appentus on 1/3/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import AVKit
import KRProgressHUD
import SwiftyJSON
import SDWebImage


class Upload_Photos_VC: UIViewController {
    @IBOutlet weak var coll_upload_photos:UICollectionView!
    
    var arr_add_image = [UIImage]()
    var arrSelectedImage = [UIImage]()
    var arr_added = [Bool]()
    
    var index = Int()
    
    var isPhoto = false
    var isEditProfile = false
    
    @IBOutlet weak var btnNext:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<4 {
            arr_add_image.append(UIImage (named:"Add Image.png")!)
            arr_added.append(false)
        }
        
        if isEditProfile {
            btnNext.isHidden = true
            let hud = KRProgressHUD.showOn(self)
            ViewControllerUtils.shared.showActivityIndicator()
            DispatchQueue.global().async {
                for i in 0..<signUp!.userPhotos.count {
                    let encodedString = signUp!.userPhotos[i].userPhotos.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)
                    self.arr_add_image[i] = (k_Base_URL_Imgae+encodedString!).urlToImage
                    self.arr_added[i] = true
                }
                DispatchQueue.main.async {
                    ViewControllerUtils.shared.hideActivityIndicator()

                    self.coll_upload_photos.reloadData()
                }
            }
        }
        
    }
    
    func func_update_photos(_ image:UIImage) {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":signUp!.userID,"photo_id":signUp!.userPhotos[index].photoID]
        APIFunc.postAPI_Image("update_photos",image.jpegData(compressionQuality: 0.3),param,"photos") { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                if json.dictionaryObject == nil {
                    return
                }
                let status = return_status(json.dictionaryObject!)
                
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            signUp = try decoder.decode(SignUp.self, from: jsonData)
                            if signUp!.saveSignUp(json) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                    hud.showSuccess(withMessage: "\(json["message"])")
                                })
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                    hud.showError(withMessage: "\(json["message"])")
                                })
                            }
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
    
     func funcAddPhotos(_ image:UIImage) {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        let param = ["user_id":signUp!.userID]
        
        var arr_data = [Data]()
        arr_data.append(image.jpegData(compressionQuality:0.2)!)
        
        APIFunc.postAPI_Images("add_photos",arr_data, param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                if json.dictionaryObject == nil {
                    return
                }
                let status = return_status(json.dictionaryObject!)
                
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            signUp = try decoder.decode(SignUp.self, from: jsonData)
                            if signUp!.saveSignUp(json) {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                    hud.showSuccess(withMessage: "\(json["message"])")
                                })
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                    hud.showError(withMessage: "\(json["message"])")
                                })
                            }
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
    
    
    @IBAction func btn_next(_ sender:UIButton) {
        if arrSelectedImage.count == 0 {
            if !self.isEditProfile {
                self.func_Next_VC_Main_1("She_Rules_ViewController")
            }
            return
        }
        
        isPhoto = false
        
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        let param = ["user_id":signUp!.userID]
        
        var arr_data = [Data]()
        for image in arrSelectedImage {
            arr_data.append(image.jpegData(compressionQuality:0.2)!)
        }
        
        APIFunc.postAPI_Images("add_photos",arr_data, param) { (json,status,message) in
            DispatchQueue.main.async {
                ViewControllerUtils.shared.hideActivityIndicator()

                if json.dictionaryObject == nil {
                    return
                }
                let status = return_status(json.dictionaryObject!)
                
                switch status {
                case .success:
                    let decoder = JSONDecoder()
                    if let jsonData = json[result_resp].description.data(using: .utf8) {
                        do {
                            signUp = try decoder.decode(SignUp.self, from: jsonData)
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                                hud.showSuccess(withMessage: "\(json["message"])")
                                DispatchQueue.main.asyncAfter(deadline: .now()+1.3, execute: {
                                signUp?.saveSignUp(json)
                                    if self.isEditProfile {
                                        self.navigationController?.popViewController(animated:true)
                                    } else {
                                        self.func_Next_VC_Main_1("She_Rules_ViewController")
                                    }
                                })
                            })
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



extension Upload_Photos_VC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr_add_image.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! Upload_Photos_CollectionViewCell
        
        cell.btn_add_image.layer.cornerRadius = cell.btn_add_image.bounds.height/2
        cell.btn_add_image.clipsToBounds = true
        
        cell.btn_add_image.setImage(arr_add_image[indexPath.row], for: .normal)
        cell.btn_add_image.tag = indexPath.row
        cell.btn_add_image.addTarget(self, action: #selector(func_OpenCamera(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width/3-8
        return CGSize (width: width, height: width)
    }
   
}



extension Upload_Photos_VC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        let alert = UIAlertController(title: "", message: "Please select!", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
//                self.func_OpenCamera()
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
    
    @IBAction func func_OpenCamera(_ sender:UIButton) {
        index = sender.tag
        func_OpenGallary()
    }
    
    func func_OpenGallary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        isPhoto = true
        
        if isEditProfile {
            if let pickedImage = info[.originalImage] as? UIImage {
                if arr_add_image[index] == UIImage (named:"Add Image.png")! {
                    picker.dismiss(animated:true) {
                        self.funcAddPhotos(pickedImage)
                    }
                } else {
                    picker.dismiss(animated:true) {
                        self.func_update_photos(pickedImage)
                    }
                }
                
                if arrSelectedImage.count > index {
                    arrSelectedImage[index] = pickedImage
                } else {
                    arrSelectedImage.append(pickedImage)
                }
                
                arr_add_image[index] = pickedImage
                arr_added[index] = true
                coll_upload_photos.reloadData()
            }
        } else {
            if let pickedImage = info[.originalImage] as? UIImage {
                if arrSelectedImage.count > index {
                    arrSelectedImage[index] = pickedImage
                } else {
                    arrSelectedImage.append(pickedImage)
                }
                
                arr_add_image[index] = pickedImage
                arr_added[index] = true
                coll_upload_photos.reloadData()
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
}



