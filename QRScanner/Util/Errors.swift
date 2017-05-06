//
// Created by Alexander Semenov on 5/6/17.
// Copyright (c) 2017 Dev Challenge. All rights reserved.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension NSError {
    func isNetworkError() -> Bool {
        //this error is fired while try to fetch url via NSData contentsOf: URL
        if (domain == NSCocoaErrorDomain && code == NSFileReadUnknownError) {
            return true
        }
        if (domain == NSURLErrorDomain) {
            return true
        }
        return false
    }
}