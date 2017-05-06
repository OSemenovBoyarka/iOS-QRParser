//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

protocol ItemParser : class {

    // parses given input synchronously - be sure to call this method in background
    func parse(input: String) throws -> [Item]
}