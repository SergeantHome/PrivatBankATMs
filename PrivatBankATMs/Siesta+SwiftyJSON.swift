//
//  Siesta+SwiftyJSON.swift
//  PrivatBankATMs
//
//  Created by Serhii Riabchun on 9/19/17.
//  Copyright © 2017 Self Education. All rights reserved.
//

import SwiftyJSON
import Siesta

let SwiftyJSONTransformer =
    ResponseContentTransformer(transformErrors: true)
    { JSON($0.content as AnyObject) }

extension TypedContentAccessors {
    var json: JSON {
        return typedContent(ifNone: JSON.null)
    }
}
