//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

class XMLItemParser : NSObject, ItemParser {

    fileprivate var xmlParser: XMLParser?

    fileprivate var results: [Item] = []

    fileprivate var currentItem: Item?

    fileprivate var currentElementName: String?

    fileprivate var currentParsedData: String?

    fileprivate var haveMoreToParse = false

    func parse(input: String) throws -> [Item] {
        currentParsedData = input

        defer {
            //we need to release resources no matter of parsing results
            currentParsedData = nil
            currentItem = nil
            currentElementName = nil
            results = []
            self.xmlParser = nil
        }

        haveMoreToParse = true
        //this is dirty hack to workaround issue that XMLParser is not able to parse document with multiple root nodes
        while (haveMoreToParse) {
            if let moreDataToParse = currentParsedData {
                startParsing(chunk: moreDataToParse)
            }
        }
        if (!results.isEmpty){
            return results
        } else if let error = xmlParser?.parserError {
            throw error
        } else {
            throw "Parsing failed for unknown reason"
        }

    }

    private func startParsing(chunk: String) {
        //reset more data flag to avoid infinite recursion
        self.haveMoreToParse = false

        let inputData = chunk.data(using: String.Encoding.utf8)!
        let xmlParser = XMLParser(data: inputData)

        defer {
            xmlParser.delegate = nil
        }

        self.xmlParser = xmlParser
        xmlParser.delegate = self
        let parseSuccess = xmlParser.parse()

        print("parsing success:\(parseSuccess)")


    }
}

extension XMLItemParser : XMLParserDelegate {

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML: Parser error occured \(parseError) on line \(parser.lineNumber) column \(parser.columnNumber)")

        let nsError = parseError as NSError
        guard nsError.domain == XMLParser.errorDomain else { return }

        //we have more content - need to restart parser using it to find all items
        if nsError.code == XMLParser.ErrorCode.prematureDocumentEndError.rawValue {
            guard let currentInput = currentParsedData else {return}

            var errorLineContent = ""
            var currentLineNumber = 1
            currentInput.enumerateLines { (line: String, stop: inout Bool) -> () in
                if (currentLineNumber == parser.lineNumber) {
                    errorLineContent = line
                    stop = true
                }
                currentLineNumber += 1
            }

            guard let currentLineRange = currentInput.range(of: errorLineContent) else {
                //something went wrong - cant find failing string
                return
            }

            currentParsedData = currentInput.substring(from: currentLineRange.lowerBound)
            print("New string for parsing: \(String(describing: currentParsedData))")
            self.haveMoreToParse = true
        }
        
    }


    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        currentElementName = elementName

        //found and item - start parsing it
        if (currentItem == nil) {
            currentItem = Item(id: elementName)
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElementName = nil

        if let currentItem = self.currentItem {
            if (elementName == currentItem.id) {
                results.append(currentItem)
                //finished parsing item
                self.currentItem = nil
            }
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let elementName = self.currentElementName else { return}

        switch elementName {
            case "name":
                currentItem?.name = string
                break;
            case "quantity":
                currentItem?.quantity = Int(string)
                break;
            case "price":
                if let price = Double(string) {
                    currentItem?.price = Decimal(price)
                }
                break;
            default:
                break;
        }

    }


}
