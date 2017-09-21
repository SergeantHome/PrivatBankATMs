//
//  APIManager.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/19/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import Siesta
import SwiftyJSON

final class APIManager {
    
    static let shared = APIManager()
    
    private let service = Service(baseURL: "https://api.privatbank.ua/p24api")
    
    fileprivate init() {
        Siesta.LogCategory.enabled = LogCategory.all
        
        service.configure {
            $0.pipeline[.parsing].add(SwiftyJSONTransformer, contentTypes: ["*/json"])
            $0.headers["Accept"] = "application/json"
        }
        
        service.configureTransformer("/infrastructure") {
            CityATMsResponse(json: $0.content)
        }
    }
    
    func cityResource(_ city: String) -> Resource {
        return service
            .resource("/infrastructure")
            .withParam("json", "")
            .withParam("atm", "")
            .withParam("city", city)
    }
}
