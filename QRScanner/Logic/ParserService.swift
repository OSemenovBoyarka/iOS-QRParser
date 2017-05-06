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

    private(set) var parsingInProgress: Bool = false

    private let parsingQueue = DispatchQueue.global(qos: .userInitiated)

    private let parsers: [ItemParser] = [JSONItemParser(), XMLItemParser()];

    func parse(code: String) {
        parsingQueue.async {

            var dataToParse: String = code
            //we can have urls in our codes - try to detect it
            do {
                if let codeFromUrl = try self.fetchCodeFromUrl(scannedCode: code) {
                    dataToParse = codeFromUrl
                }
            } catch {
                //we received url, but download failed
                DispatchQueue.main.async {
                    self.delegate?.didFinishParsing(result: ParsingResult(items: nil, error: error as NSError))
                }
            }

            //actual parsing
            self.parse(data: dataToParse, usingParsers: self.parsers)
        }

        //notify delegate, parsing have started
        DispatchQueue.main.async {
            self.delegate?.didStartParsing(code: code)
        }
    }

    private func parse(data: String, usingParsers: [ItemParser]) {
        print("Parsing data: \(data) ")
        var parsedItems: [Item]?

        //try all parsers until one succeeds
        for parser in self.parsers {
            do {
                parsedItems = try parser.parse(input: data)
                //we've parsed our items = nothing to do here more
                if (parsedItems!.isEmpty == false) {
                    break;
                }
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

    private func fetchCodeFromUrl(scannedCode: String) throws -> String? {
        guard let url = URL(string: scannedCode) else {
            //not an url
            return nil
        }
        print("got URL: \(url)")
        do {
            let data = try Data(contentsOf: url)
            return String(data: data, encoding: String.Encoding.utf8)!
        } catch {
            print("failed to download data: \(error)")
            throw error
        }
    }


}
