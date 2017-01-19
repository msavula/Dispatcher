//
//  ServiceRequestHandler.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class ServiceRequestHandler: RequestHandler {
    
    // MARK: loggin
    func logNetworkRequest(request: URLRequest) {
        
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
    
    func logNetworkResponse(response: URLResponse?, error: Error?, data: Data?) {
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
    
    // MARK: globals
    // enclosing defaults structure
    private struct serviceDefaults {
        private(set) var logNetwork: Bool?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                logNetwork = plist["LOG_NETWORK"] as? Bool
            }
        }
    }
    
    private static let defaults = serviceDefaults()
    
    // MARK: processing
    override func processRequest(request: Request, error: Error?) {
        var error = error
        
        let serviceRequest = request.serviceURLRequest()
        
        if let logNetwork = ServiceRequestHandler.defaults.logNetwork, logNetwork == true {
            logNetworkRequest(request: serviceRequest)
        }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: serviceRequest) {
            data, response, networkError in
            
            if let logNetwork = ServiceRequestHandler.defaults.logNetwork, logNetwork == true {
                self.logNetworkResponse(response: response, error: networkError, data: data)
            }
            
            if request.canceled {
                print("request cancelled: \(request)")
            } else if networkError != nil {
                error = networkError
            } else {
                do {
                    try request.response.parseResponse(response: response, data: data)
                } catch let parsingError {
                    error = parsingError
                }
            }
            
            semaphore.signal()
        }
        
        if request.cancelation == nil {
            request.cancelation = {
                task.cancel()
                semaphore.signal()
            }
        }
        
        task.resume()
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            // TODO: handle timeout (throw error)
        }
        
        super.processRequest(request: request, error: error)
    }
}
