//  FullPictureVC.swift
//  SheDistrict
//  Created by appentus on 3/16/20.
//  Copyright © 2020 appentus. All rights reserved.

import UIKit
import AVKit
import KRProgressHUD

protocol DelegateFullPictureVC {
    func funcReplace()
}

class FullPictureVC: UIViewController {
    @IBOutlet weak var view_container:UIView!
    @IBOutlet weak var img_user:UIImageView!
    @IBOutlet weak var imgContainer:UIView!
    
    @IBOutlet weak var btnCancel:UIButton!
    @IBOutlet weak var btnRemove:UIButton!
    @IBOutlet weak var btnReplace:UIButton!
    
    var buttonsShow = 0
    var imgUrl = ""
    var selectedUserPhotos:UserPhoto?
    
    var delegate:DelegateFullPictureVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imgContainer.layer.masksToBounds = false
//        imgContainer.layer.shadowColor = hexStringToUIColor("FECF03").cgColor
//        imgContainer.layer.shadowPath = UIBezierPath(roundedRect:imgContainer.bounds, cornerRadius:imgContainer.layer.cornerRadius).cgPath
//        imgContainer.layer.shadowOffset = CGSize(width: 0.0, height:5)
//        imgContainer.layer.shadowOpacity = 0.3
//        imgContainer.layer.shadowRadius = 8
//        
//        imgContainer.layer.cornerRadius = imgContainer.frame.height/2
//        
//        view_container.layer.cornerRadius = view_container.frame.height/2
//        view_container.clipsToBounds = true
//        
//        img_user.layer.cornerRadius = img_user.frame.height/2
//        img_user.clipsToBounds = true
        
        if buttonsShow == 1 {
            btnCancel.isHidden = false
            btnRemove.isHidden = true
            btnReplace.isHidden = true
        } else if buttonsShow == 2 {
            btnCancel.isHidden = false
            btnRemove.isHidden = true
            btnReplace.isHidden = false
        } else if buttonsShow == 3 {
            btnCancel.isHidden = false
            btnRemove.isHidden = false
            btnReplace.isHidden = false
        } else {
            btnCancel.isHidden = false
            btnRemove.isHidden = false
            btnReplace.isHidden = false
        }
        
        img_user.sd_setImage(with: URL(string:imgUrl), placeholderImage:k_default_user)
    }
        
    @IBAction func btnCancel (_ sender:UIButton) {
        func_removeFromSuperview()
    }
    
    @IBAction func btnRemove (_ sender:UIButton) {
            
    }
    
    @IBAction func btnReplace (_ sender:UIButton) {
        func_ChooseImage(sender)
    }
        
}



extension FullPictureVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func func_camera_permission(completion:@escaping (Bool)->()) {
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
    
    @IBAction func func_ChooseImage(_ sender:UIButton) {
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
    
    private func func_OpenCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            func_camera_permission { (is_permission) in
                if is_permission {
                    DispatchQueue.main.async {
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let alert  = UIAlertController(title: "Warning!", message: "You don't have camera in simulator", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func func_OpenGallary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.allowsEditing = true
        imagePicker.delegate=self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            img_user.image = pickedImage
        }
        picker.dismiss(animated: true, completion:{
            if self.selectedUserPhotos == nil {
                self.funcCreateProfile()
            } else {
                self.func_update_photos()
            }
        })
    }
    
    func funcCreateProfile() {
        let parameters = [
            "user_id":signUp!.userID,
            "user_bio":"",
            "user_intro":"",
            "user_bio_video":"",
            "user_bio_image":""
        ]
        
        let hud = KRProgressHUD.showOn(self)
                ViewControllerUtils.shared.showActivityIndicator()

        let data = img_user.image!.jpegData(compressionQuality: 0.2)
        APIFunc.postAPI_Image("create_profile", data, parameters, "profile") { (json,status,message)  in
            DispatchQueue.main.async {
                        ViewControllerUtils.shared.hideActivityIndicator()
                if json.dictionaryObject == nil {
                    return
                }
                
                let status = return_status(json.dictionaryObject!)
                switch status {
                case .success:
                    if signUp!.saveSignUp(json) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                            hud.showSuccess(withMessage:"Profile picture upated successfully")
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                self.func_removeFromSuperview()
                                self.delegate?.funcReplace()
                            })
                        })
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
        
    func func_update_photos() {
        let hud = KRProgressHUD.showOn(self)
        ViewControllerUtils.shared.showActivityIndicator()
        
        let param = ["user_id":signUp!.userID,"photo_id":selectedUserPhotos!.photoID]
        APIFunc.postAPI_Image("update_photos",img_user.image!.jpegData(compressionQuality: 0.3),param,"photos") { (json,status,message) in
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
                                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                        self.func_removeFromSuperview()
                                        self.delegate?.funcReplace()
                                    })
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
    
    
}



