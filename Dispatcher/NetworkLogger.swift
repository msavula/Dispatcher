//
//  NetworkLogger.swift
//  Dispatcher
//
//  Created by Nick Savula  on 7/16/18.
//  Copyright © 2018 Nick Savula. All rights reserved.
//

import Foundation

class NetworkLogger {
    class func logNetworkRequest(request: URLRequest) {
        
        var headers = ""
        if let headerFields = request.allHTTPHeaderFields {
            for (key, value) in headerFields {
                headers.append("    \(key): \(value)\n")
            }
        }
        
        var body = "    <empty>"
        if let data = request.httpBody, data.count > 0 {
            if data.count > 2048 {
                body = String("    <\(data.count) bytes>")
            } else if let dataString = String(data: data, encoding: .utf8) {
                body = dataString
            }
        }
        
        if let url = request.url?.absoluteString, let method = request.httpMethod {
            print("\n----- [NETWORK REQUEST] -----\n  URL: \(url)\n  METHOD: \(method)\n  HEADER FIELDS\n\(headers)  BODY\n  \(body)\n-----------------------------\n")
        }
    }
    
    class func logNetworkResponse(response: URLResponse?, error: Error?, data: Data?) {
        if let networkError = error {
            print("\n----- [NETWORK RESPONSE] -----\n  ERROR: \(networkError.localizedDescription)\n")
        } else if let networkResponse = response as? HTTPURLResponse  {
            var headers = ""
            for (key, value) in networkResponse.allHeaderFields {
                headers.append("    \(key): \(value)\n")
            }
            
            var body = "    <empty>"
            if let responseData = data, responseData.count > 0 {
                if let dataString = String(data: responseData, encoding: .utf8) {
                    body = dataString
                }
            }
            
            if let url = networkResponse.url?.absoluteString {
                print("\n----- [NETWORK RESPONSE] -----\n  URL: \(url)\n  STATUS CODE: \(networkResponse.statusCode)\n  HEADER FIELDS\n\(headers)  BODY\n    \(body)\n------------------------------\n")
            }
        }
    }
}
