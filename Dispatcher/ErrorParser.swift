//
//  ErrorParser.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/26/17.
//  Copyright © 2017 Nick Savula. All rights reserved.
//

import Foundation

protocol ErrorParsing {
    func isSuccessfulHTTPStatus(status: Int) -> Bool
    func parseError(json: Any?, statusCode: Int) throws
}

class ErrorParser: ErrorParsing {
    
    private struct errorParserDefaults {
        private(set) var successStatusCodes: Array<String>?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                successStatusCodes = plist["SUCESS_STATUS_CODES"] as? Array
            }
        }
    }
    
    enum WebserviceError: Error {
        case genericError(reason: String, message: String)
        case unknownError
    }
    
    enum ParsingError: Error {
        case nothingToParse
    }
    
    private static let defaults = errorParserDefaults()
    
    func isSuccessfulHTTPStatus(status: Int) -> Bool {
        if let successStatusCodes = ErrorParser.defaults.successStatusCodes {
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
    
    func parseError(json: Any?, statusCode: Int) throws {
        if let json = json {
            
            if !isSuccessfulHTTPStatus(status: statusCode) {
                if let jsonDictionary = json as? Dictionary<String, Any>,  let reason = jsonDictionary["error"] as? String, let message = jsonDictionary["error_description"] as? String {
                    throw WebserviceError.genericError(reason: reason, message: message)
                } else {
                    throw WebserviceError.unknownError
                }
            }
        } else if !isSuccessfulHTTPStatus(status: statusCode) {
            throw ParsingError.nothingToParse
        }
    }
}
