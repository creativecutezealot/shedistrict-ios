//
//  GetViewers.swift
//  SheDistrict
//
//  Created by Ayush Pathak on 11/06/20.
//  Copyright © 2020 appentus. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getViewers = try? newJSONDecoder().decode(GetViewers.self, from: jsonData)

import Foundation

// MARK: - GetViewers
class GetViewers: Codable {
    let id, userID, viewerID, created: String
    let userProfile, userName, userEmail, userPassword: String
    let passwordString, userCountryCode, userMobile, userDob: String
    let userLoginType, userSocial, userDeviceType, userDeviceToken: String
    let userLat, userLang, userStatus, role: String
    let aboutMe, friendLike, describeMe, hobbies: String
    let interestInfo, personalInfo, allowMsg, premiumData: String
    let hideProfile, hideActivity, stopInvite, hideLocation: String
    let hideAge, userDeactive, pushStatus, pushSetting: String
    let question, answer, sheProtect, isOnline: String
    let twitterLink: String
    let isBoosts: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case viewerID
        case created
        case userProfile
        case userName
        case userEmail
        case userPassword
        case passwordString
        case userCountryCode
        case userMobile
        case userDob
        case userLoginType
        case userSocial
        case userDeviceType
        case userDeviceToken
        case userLat
        case userLang
        case userStatus
        case role
        case aboutMe
        case friendLike
        case describeMe
        case hobbies
        case interestInfo
        case personalInfo
        case allowMsg
        case premiumData
        case hideProfile
        case hideActivity
        case stopInvite
        case hideLocation
        case hideAge
        case userDeactive
        case pushStatus
        case pushSetting
        case question, answer
        case sheProtect
        case isOnline
        case twitterLink
        case isBoosts
    }

    init(id: String, userID: String, viewerID: String, created: String, userProfile: String, userName: String, userEmail: String, userPassword: String, passwordString: String, userCountryCode: String, userMobile: String, userDob: String, userLoginType: String, userSocial: String, userDeviceType: String, userDeviceToken: String, userLat: String, userLang: String, userStatus: String, role: String, aboutMe: String, friendLike: String, describeMe: String, hobbies: String, interestInfo: String, personalInfo: String, allowMsg: String, premiumData: String, hideProfile: String, hideActivity: String, stopInvite: String, hideLocation: String, hideAge: String, userDeactive: String, pushStatus: String, pushSetting: String, question: String, answer: String, sheProtect: String, isOnline: String, twitterLink: String, isBoosts: Int) {
        self.id = id
        self.userID = userID
        self.viewerID = viewerID
        self.created = created
        self.userProfile = userProfile
        self.userName = userName
        self.userEmail = userEmail
        self.userPassword = userPassword
        self.passwordString = passwordString
        self.userCountryCode = userCountryCode
        self.userMobile = userMobile
        self.userDob = userDob
        self.userLoginType = userLoginType
        self.userSocial = userSocial
        self.userDeviceType = userDeviceType
        self.userDeviceToken = userDeviceToken
        self.userLat = userLat
        self.userLang = userLang
        self.userStatus = userStatus
        self.role = role
        self.aboutMe = aboutMe
        self.friendLike = friendLike
        self.describeMe = describeMe
        self.hobbies = hobbies
        self.interestInfo = interestInfo
        self.personalInfo = personalInfo
        self.allowMsg = allowMsg
        self.premiumData = premiumData
        self.hideProfile = hideProfile
        self.hideActivity = hideActivity
        self.stopInvite = stopInvite
        self.hideLocation = hideLocation
        self.hideAge = hideAge
        self.userDeactive = userDeactive
        self.pushStatus = pushStatus
        self.pushSetting = pushSetting
        self.question = question
        self.answer = answer
        self.sheProtect = sheProtect
        self.isOnline = isOnline
        self.twitterLink = twitterLink
        self.isBoosts = isBoosts
    }
}
