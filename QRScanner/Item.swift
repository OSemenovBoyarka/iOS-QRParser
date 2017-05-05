//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

class Item {

    var id: String
    var price: Decimal?
    var name: String?
    var quantity: Int?

    init(id: String){
        self.id = id
    }
}