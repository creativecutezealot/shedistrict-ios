//  ModelEvents.swift
//  SheDistrict
//  Created by Appentus Technologies on 2/10/20.
//  Copyright © 2020 appentus. All rights reserved.


import Foundation


struct ScheduleEvents: Codable {
    let meetingID, meetingUserID, meetingFriendID, meetingSubject: String?
    let meetingReason, meetingDate, meetingTime, meetingLocation: String?
    let created, meetingStatus, userName, userProfile: String?
    let text, type,friName: String?
    
    enum CodingKeys: String, CodingKey {
        case meetingID = "meeting_id"
        case meetingUserID = "meeting_user_id"
        case meetingFriendID = "meeting_friend_id"
        case meetingSubject = "meeting_subject"
        case meetingReason = "meeting_reason"
        case meetingDate = "meeting_date"
        case meetingTime = "meeting_time"
        case meetingLocation = "meeting_location"
        case created
        case meetingStatus = "meeting_status"
        case userName = "user_name"
        case userProfile = "user_profile"
        case friName = "fri_name"
        case text, type
    }
}

var scheduleEvents:[ScheduleEvents] = []


