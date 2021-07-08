//  AppDelegate.swift
//  SheDistrict
//  Created by appentus on 1/1/20.
//  Copyright © 2020 appentus. All rights reserved.


import UIKit
import IQKeyboardManagerSwift
import Firebase
import FBSDKCoreKit
import KRProgressHUD


var isOnApp = false


let YOUR_API_KEY = "AIzaSyAQjbgAlcLy8p5psauhCA8gqQjIDU0GD0A"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        
        IQKeyboardManager.shared.enable = true
        func_firebase()
        
        askForNotificationPermission(application)
        
        NotificationCenter.default.addObserver(self, selector:#selector(notifRecieveInactive), name: NSNotification.Name (rawValue:"notifRecieveInactive"), object: nil)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}



import Firebase
import FirebaseMessaging
var k_FireBaseFCMToken = ""



extension AppDelegate : MessagingDelegate {
    func func_firebase()  {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        k_FireBaseFCMToken = fcmToken
    }
    
}



import UserNotifications
extension AppDelegate:UNUserNotificationCenterDelegate {
    func openNotificationInSettings() {
        let alertController = UIAlertController(title: "Notification Alert", message: "Please enable Notification from Settings to never miss a text.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func askForNotificationPermission(_ application: UIApplication) {
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if !isRegisteredForRemoteNotifications {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                    (granted, error) in
                    if error == nil {
                        UNUserNotificationCenter.current().delegate = self
                    }
                }
            } else {
                // Fallback on earlier versions
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
        } else {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self
            } else {
                // Fallback on earlier versions
            }
        }
        application.registerForRemoteNotifications()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        let dictUserInfo = userInfo as! [String:Any]
        
        let dictResult = "\(dictUserInfo["gcm.notification.result"]!)".dictionary
        print(dictResult)
        
        if extractUserInfo(userInfo).title.lowercased() == "New message".lowercased() {
//            if let topController = UIApplication.shared.keyWindow?.rootViewController {
//                if let navCOnt = topController as? UINavigationController{
//                    print(navCOnt.viewControllers)
//                    if (navCOnt.viewControllers.last?.isKind(of: Chat_ViewController.self))!{
//                        completionHandler([])
//                    }else{
//                        completionHandler([.alert, .badge, .sound])
//                    }
//                }
//            }
            completionHandler( [.alert, .badge, .sound])
            NotificationCenter.default.post(name: NSNotification.Name (rawValue:"newMessage"), object:nil)
        } else if extractUserInfo(userInfo).title.lowercased() == "Meeting invitation".lowercased() {
            completionHandler( [.alert, .badge, .sound])
            
            NotificationCenter.default.post(name: NSNotification.Name (rawValue:"sendInvitaion"), object:nil)
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        let userInfo = response.notification.request.content.userInfo
        
        switch UIApplication.shared.applicationState {
        case .active:
            funcTapNotification(userInfo)
            break
        case .inactive:
            dictNotifRecieveInactive = userInfo
            if isOnApp {
                funcTapNotification(userInfo)
            }
            break
        case .background:
            funcTapNotification(userInfo)
            break
        default:
            break
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @objc func notifRecieveInactive(_ noti:Notification) {
        if extractUserInfo(noti.userInfo!).title.lowercased() == "New message".lowercased() {
            let dictResult = "\(noti.userInfo!["gcm.notification.result"]!)".dictionary
            
            let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
            let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
            
            chat_VC.user = User (userID:"\(dictResult["user_id"]!)", userProfile:"", userName:"\(dictResult["user_name"]!)", userEmail: "", userPassword: "", userCountryCode: "", userMobile: "", userDob: "", userLoginType: "", userSocial: "", userDeviceType: "", userDeviceToken: "", userLat: "", userLang: "", userStatus: "", created: "")
            
            dictNotifRecieveInactive.removeAll()
            
            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController(chat_VC, animated: true)
        } else if extractUserInfo(noti.userInfo!).title.lowercased() == "Meeting invitation".lowercased() {
            NotificationCenter.default.post(name: NSNotification.Name (rawValue:"notiInactiveEvent"), object:nil)
        }
    }
    
    func funcTapNotification(_ userInfo:[AnyHashable:Any]) {
        let dictResult = "\(userInfo["gcm.notification.result"]!)".dictionary
        if extractUserInfo(userInfo).title.lowercased() == "New message".lowercased() {
            
            let storyboard = UIStoryboard (name: "Main_2", bundle: nil)
            let chat_VC = storyboard.instantiateViewController(withIdentifier:"Chat_ViewController") as! Chat_ViewController
            chat_VC.user = User (userID:"\(dictResult["sender_id"]!)", userProfile:"\(dictResult["friend_profile"]!)", userName:"\(dictResult["friend_name"]!)", userEmail: "", userPassword: "", userCountryCode: "", userMobile: "", userDob: "", userLoginType: "", userSocial: "", userDeviceType: "", userDeviceToken: "", userLat: "", userLang: "", userStatus: "", created: "")
            
            dictNotifRecieveInactive.removeAll()
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                if let navCOnt = topController as? UINavigationController{
                    print(navCOnt.viewControllers)
                    if (navCOnt.viewControllers.last?.isKind(of: Chat_ViewController.self))!{
                        print(topController)
                    }else{
                        let rootViewController = self.window!.rootViewController as! UINavigationController
                        rootViewController.pushViewController(chat_VC, animated: true)
                    }
                }
            }
        } else if extractUserInfo(userInfo).title.lowercased() == "Meeting invitation".lowercased() {
            NotificationCenter.default.post(name: NSNotification.Name (rawValue:"notiInactiveEvent"), object:nil)
        }
    }
}
