//
//  Request.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation
import CoreData

class Request {
    
    static var errorParser: ErrorParsing = ErrorParser()
    
    // MARK response
    class Response {
        
        enum ResponseError: Error {
            case invalidResponse
        }
        
        private(set) var json: Any?
        
        func parseResponse(response: URLResponse?, data: Data?) throws {
            if let httpResonse = response as? HTTPURLResponse {
                if let jsonData = data {
                    try json = JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    
                    try errorParser.parseError(json: json, statusCode: httpResonse.statusCode)
                } else {
                    throw ResponseError.invalidResponse
                }
            }
        }
    }
    
    // MARK: globals
    // enclosing defaults structure
    private struct requestDefaults {
        private(set) var timeoutInterval: TimeInterval?
        private(set) var method: String?
        private(set) var headers: Dictionary<String, String>?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                timeoutInterval = plist["TIMEOUT_INTERVAL"] as? TimeInterval
                method = plist["DEFAULT_METHOD"] as? String
                headers = plist["HTTP_HEADERS"] as? Dictionary
            }
        }
    }
    
    let owner: ObjectIdentifier
    private static let defaults = requestDefaults()
    lazy private(set) var response = Response()
    
    init(owner: ObjectIdentifier) {
        self.owner = owner
    }
    
    func serviceURLRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: "www.google.com")!)
        
        if let timeoutInterval = Request.defaults.timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        if let method = Request.defaults.method {
            request.httpMethod = method
        }
        
        if let headers = Request.defaults.headers {
            for (headerField, value) in headers {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        
        return request
    }
    
    // MARK: lifecycle
    var completed = false
    var canceled = false
    
    // reporting
    var completion: ((_ request: Request, _ error: Error?) -> Void)?
    var cacheCompletion: ((_ cache: [NSManagedObject]) -> Void)?
    var cancelation: (() -> Void)?
    
    func cancel() -> Bool {
        if canceled {
            return false
        }
        
        canceled = true
        if let closure = cancelation {
            closure()
        }
        
        return true
    }
}

extension Request: Hashable {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    static func ==(lhs: Request, rhs: Request) -> Bool {
        return ObjectIdentifier(lhs).hashValue == ObjectIdentifier(rhs).hashValue
    }
}
