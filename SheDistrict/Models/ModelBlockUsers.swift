//
//  ModelBlockUsers.swift
//  SheDistrict
//
//  Created by appentus on 2/25/20.
//  Copyright © 2020 appentus. All rights reserved.
//

import Foundation



// MARK: - GetBlockUserElement
struct GetBlockUser: Codable {
    let roomID, friID, userID, created: String?
    let blockStatus, userProfile, userName, userEmail: String?
    let userPassword, userCountryCode, userMobile, userDob: String?
    let userLoginType, userSocial, userDeviceType, userDeviceToken: String?
    let userLat, userLang, userStatus, role: String?
    let aboutMe, friendLike, describeMe, hobbies: String?
    let interestInfo, personalInfo, allowMsg, premiumData: String?
    let hideProfile, hideActivity, stopInvite, hideLocation: String?
    let hideAge, userDeactive, pushStatus, pushSetting: String?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case friID = "fri_id"
        case userID = "user_id"
        case created
        case blockStatus = "block_status"
        case userProfile = "user_profile"
        case userName = "user_name"
        case userEmail = "user_email"
        case userPassword = "user_password"
        case userCountryCode = "user_country_code"
        case userMobile = "user_mobile"
        case userDob = "user_dob"
        case userLoginType = "user_login_type"
        case userSocial = "user_social"
        case userDeviceType = "user_device_type"
        case userDeviceToken = "user_device_token"
        case userLat = "user_lat"
        case userLang = "user_lang"
        case userStatus = "user_status"
        case role
        case aboutMe = "about_me"
        case friendLike = "friend_like"
        case describeMe = "describe_me"
        case hobbies
        case interestInfo = "interest_info"
        case personalInfo = "personal_info"
        case allowMsg = "allow_msg"
        case premiumData = "premium_data"
        case hideProfile = "hide_profile"
        case hideActivity = "hide_activity"
        case stopInvite = "stop_invite"
        case hideLocation = "hide_location"
        case hideAge = "hide_age"
        case userDeactive = "user_deactive"
        case pushStatus = "push_status"
        case pushSetting = "push_setting"
    }
}

var getBlockUser:[GetBlockUser] = []
