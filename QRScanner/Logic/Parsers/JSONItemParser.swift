//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

class JSONItemParser: ItemParser {
    func parse(input: String) throws -> [Item] {
        let inputData = input.data(using: String.Encoding.utf8)!

        let parsedResult = try JSONSerialization.jsonObject(with: inputData, options: [JSONSerialization.ReadingOptions.allowFragments])

        guard let parsedDictionary = parsedResult as? [String : Any] else {
            throw "JSON object \(input) doesn't contain any known items"
        }

        var result : [Item] = []
        for key in parsedDictionary.keys {
            let item = Item(id: key)

            guard let itemData = parsedDictionary[key] as? [String: Any] else {
                print("Unknown item: \(String(describing: parsedDictionary[key])), skipping")
                continue
            }

            item.name = itemData["name"] as? String
            item.quantity = itemData["quantity"] as? Int
            //any floating numbers are parsed to Double, so we need some dirty hacking
            if let priceDouble = itemData["price"] as? Double {
                item.price = Decimal(priceDouble)
            }

            result.append(item)

        }
        return result
    }

}
