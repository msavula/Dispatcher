//
//  ServiceRequestHandler.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class ServiceRequestHandler: RequestHandler {
    // MARK: globals
    // enclosing defaults structure
    private struct serviceDefaults {
        private(set) var logNetwork: Bool?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                #if DEBUG
                    logNetwork = plist["LOG_NETWORK"] as? Bool
                #endif
            }
        }
    }
    
    private static let defaults = serviceDefaults()
    
    // MARK: processing
    override func processRequest(request: Request, error: Error?) {
        var error = error
        
        let serviceRequest = request.serviceURLRequest()
        
        if let logNetwork = ServiceRequestHandler.defaults.logNetwork, logNetwork == true {
            NetworkLogger.logNetworkRequest(request: serviceRequest)
        }
        
        let methodStart = Date()
        let semaphore = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: serviceRequest) {
            data, response, networkError in
            
            if let logNetwork = ServiceRequestHandler.defaults.logNetwork, logNetwork == true {
                NetworkLogger.logNetworkResponse(response: response, error: networkError, data: data)
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
            
            if let logNetwork = ServiceRequestHandler.defaults.logNetwork, logNetwork == true {
                let methodFinish = Date()
                let executionTime = methodFinish.timeIntervalSince(methodStart)
                print("[NETWORK REQUEST] \(serviceRequest.url?.absoluteString ?? "FATAL - invalid URL") execution time: \(executionTime)")
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
