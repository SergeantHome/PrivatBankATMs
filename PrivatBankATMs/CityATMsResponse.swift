//
//  CityATMsResponse.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/19/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import SwiftyJSON

// Корневой объект в ответе от сервера
struct CityATMsResponse {
//    let city: String?
    let devices: [ATMInfo]
    
    init(json: JSON) {
//        city = json["city"].string
        devices = json["devices"].arrayValue.map(ATMInfo.init)
    }
}
