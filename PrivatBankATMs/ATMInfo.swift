//
//  ATMInfo.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/19/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import SwiftyJSON

// Объект, содержащий информацию о банкомате
struct ATMInfo {
    enum Locale: Int {
        case ru, ua, en
    }
    
    let city: [String?]
    let fullAddress: [String?]
    let place: [String?]
    let latitude: Double?
    let longitude: Double?
    let workTime: [String?]
    
    var placeTitle: String? {
        guard let defaultLocaleTitle = place.first else {
            return nil
        }
        return defaultLocaleTitle
    }
    
    var address: String? {
        guard let defaultLocaleAddress = fullAddress.first else {
            return nil
        }
        return defaultLocaleAddress?.replacingOccurrences(of: ",", with: ", ")
    }
    
    init(json: JSON) {
        city = [json["cityRU"].string, json["cityUA"].string, json["cityEN"].string]
        fullAddress = [json["fullAddressRu"].string, json["fullAddressUa"].string, json["fullAddressEn"].string]
        place = [json["placeRu"].string, json["placeUa"].string, nil]
        latitude = Double(json["latitude"].stringValue)
        longitude = Double(json["longitude"].stringValue)
        workTime = [json["tw"]["mon"].string, json["tw"]["tue"].string, json["tw"]["wed"].string, json["tw"]["thu"].string,
                    json["tw"]["fri"].string, json["tw"]["sat"].string, json["tw"]["sun"].string, json["tw"]["hol"].string]
    }
}
