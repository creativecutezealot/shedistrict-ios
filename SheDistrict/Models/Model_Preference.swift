//  Model_Preference.swift
//  SheDistrict
//  Created by Appentus Technologies on 2/4/20.
//  Copyright © 2020 appentus. All rights reserved.

import Foundation

var preference:[Preference] = []

// MARK: - WelcomeElement
struct Preference: Codable {
    let preferenceID, preference, inputType: String
    let created:String
    let values: [Preference_Value]
    let unit: String?

    enum CodingKeys: String, CodingKey {
        case preferenceID = "preference_id"
        case preference
        case inputType = "input_type"
        case created, values, unit
    }
}

// MARK: - Value
struct Preference_Value: Codable {
    let preferenceValueID, preferenceID, valueName, created: String
    
    enum CodingKeys: String, CodingKey {
        case preferenceValueID = "preference_value_id"
        case preferenceID = "preference_id"
        case valueName = "value_name"
        case created
    }
}

