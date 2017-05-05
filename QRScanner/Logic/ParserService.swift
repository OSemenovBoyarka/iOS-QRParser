//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

protocol ParserServiceDelegate: class {

    func didFinishParsing(result: ParsingResult)

    func didStartParsing(code: String)
}


class ParserService {

    static let shared = ParserService()

    weak var delegate: ParserServiceDelegate?

    private(set) var  parsingInProgress : Bool = false

    private let parsingQueue = DispatchQueue.global(qos: .userInitiated)

    private let parsers : [ItemParser] = [JsonItemParser()];

    func parse(code: String) {
        parsingQueue.async {
            self.parse(code: code, usingParsers: self.parsers)
        }

        //notify delegate, parsing have started
        DispatchQueue.main.async {
           self.delegate?.didStartParsing(code: code)
        }
    }

    private func parse(code: String, usingParsers: [ItemParser]){
        print("Parsing: \(code) ")
        var parsedItems : [Item]?
        for parser in self.parsers {
            do {
                parsedItems = try parser.parse(input: code)
            } catch {
                print("Parser \(parser)) failed with error: \(error)")
            }
        }

        var result: ParsingResult
        if (parsedItems != nil && parsedItems!.isEmpty == false) {
            result = ParsingResult(items: parsedItems)
        } else {
            result = ParsingResult(items: nil, error: nil)
        }

        //notify delegate, parsing finished
        DispatchQueue.main.async {
            self.delegate?.didFinishParsing(result: result)
        }
    }


}
