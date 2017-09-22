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
    
    // Базовый URL API
    private let service = Service(baseURL: "https://api.privatbank.ua/p24api")
    
    fileprivate init() {
        service.configure {
            // Настраиваем парсинг JSON в объекты модели
            $0.pipeline[.parsing].add(SwiftyJSONTransformer, contentTypes: ["*/json"])
            // Указывам серверу, что мы хотим получать в ответ JSON
            $0.headers["Accept"] = "application/json"
        }
        
        service.configureTransformer("/infrastructure") {
            // Парсинг полученных объектов
            CityATMsResponse(json: $0.content)
        }
    }
    
    // Настраиваем URL для запроса списка банкоматов указанного города
    func cityResource(_ city: String) -> Resource {
        return service
            .resource("/infrastructure")
            .withParam("json", "")
            .withParam("atm", "")
            .withParam("city", city)
    }
}
