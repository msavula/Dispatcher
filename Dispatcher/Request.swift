//
//  Request.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class Request {
    
    // MARK response
    class Response {
        
        enum WebserviceError: Error {
            case genericError(reason: String, message: String)
            case unknownError
        }
        
        enum ParsingError: Error {
            case nothingToParse
        }
        
        private(set) var json: Any?
        
        private func isSuccessfulHTTPStatus(status: Int) -> Bool {
            if let successStatusCodes = Request.defaults.successStatusCodes {
                for acceptableStatus in successStatusCodes {
                    if acceptableStatus.contains("-") {
                        let components = acceptableStatus.components(separatedBy: "-")
                        if components.count == 2 {
                            if let startRange = Int(components[0]), startRange <= status, let endRange = Int(components[1]), endRange >= status {
                                return true
                            }
                        }
                    } else {
                        // we have a single code
                        if Int(acceptableStatus) == status {
                            return true
                        }
                    }
                }
            }
            
            return false
        }
        
        func parseResponse(response: URLResponse?, data: Data?) throws {
            if let httpResonse = response as? HTTPURLResponse {
                if let jsonData = data {
                    try json = JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    
                    if !isSuccessfulHTTPStatus(status: httpResonse.statusCode) {
                        if let jsonDictionary = json as? Dictionary<String, Any>,  let reason = jsonDictionary["error"] as? String, let message = jsonDictionary["error_description"] as? String {
                            throw WebserviceError.genericError(reason: reason, message: message)
                        } else {
                            throw WebserviceError.unknownError
                        }
                    }
                } else if !isSuccessfulHTTPStatus(status: httpResonse.statusCode) {
                    throw ParsingError.nothingToParse
                }
            }
        }
    }
    
    // MARK: globals
    // enclosing defaults structure
    private struct requestDefaults {
        private(set) var timeoutInterval: TimeInterval?
        private(set) var successStatusCodes: Array<String>?
        private(set) var method: String?
        private(set) var headers: Dictionary<String, String>?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                timeoutInterval = plist["TIMEOUT_INTERVAL"] as? TimeInterval
                successStatusCodes = plist["SUCESS_STATUS_CODES"] as? Array
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
