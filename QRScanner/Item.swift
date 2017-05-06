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

extension Item {

    // Calculates total price for all items. Can be nil if price or quantity not set

    func totalPrice() -> Decimal? {
        //we should have both
        guard var price = self.price else {
            print("Can't calculate total price for \(self), price not set")
            return nil
        }

        guard let quantity = self.quantity else {
            print("Can't calculate total price for \(self), quantity not set")
            return nil
        }

        price.multiply(by: Decimal(quantity))
        return price
    }
}