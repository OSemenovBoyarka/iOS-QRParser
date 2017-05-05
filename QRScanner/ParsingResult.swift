//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

class ParsingResult {

    let items: [Item]?
    let error: NSError?
    let success: Bool

    init(items: [Item]?, error: NSError? = nil){
        self.items = items
        self.error = error
        self.success = items != nil
    }
}
