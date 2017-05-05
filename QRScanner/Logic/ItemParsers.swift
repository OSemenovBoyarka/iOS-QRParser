//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

protocol ItemParser : class {
    func parse(input: String) throws -> [Item]
}

class JsonItemParser : ItemParser {
    func parse(input: String) throws -> [Item] {

        let inputData = input.data(using: String.Encoding.utf8)!
        let parsedResult = try JSONSerialization.jsonObject(with: inputData, options: [JSONSerialization.ReadingOptions.allowFragments])
        print("Parsed JSON code: \(parsedResult)")

        return []
    }
}