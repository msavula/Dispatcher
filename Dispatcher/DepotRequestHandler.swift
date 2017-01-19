//
//  DepotRequestHandler.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class DepotRequestHandler: RequestHandler {
    
    // MARK: globals
    // enclosing defaults structure
    private struct depotDefaults {
        private(set) var logDepotOperations: Bool?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                logDepotOperations = plist["LOG_DEPOT_OPERATIONS"] as? Bool
            }
        }
    }
    
    
    private var currentRequests = Set<Request>()
    private static let defaults = depotDefaults()
    
    override func processRequest(request: Request, error: Error?) {
        if let logDepot = DepotRequestHandler.defaults.logDepotOperations, logDepot == true {
            print("[REQUEST DEPOT]: adding request \(request)")
        }
        
        currentRequests.insert(request)
        
        DispatchQueue.global(qos: .userInitiated).async {
            super.processRequest(request: request, error: error)
        }
    }
    
    override func reportRequest(request: Request, error: Error?) {
        if let logDepot = DepotRequestHandler.defaults.logDepotOperations, logDepot == true {
            print("[REQUEST DEPOT]: removing request \(request)")
        }
        
        DispatchQueue.main.async {
            self.currentRequests.remove(request)
            super.reportRequest(request: request, error: error)
        }
    }
    
    override func cancelAllRequests(owner: ObjectIdentifier) {
        if let logDepot = DepotRequestHandler.defaults.logDepotOperations, logDepot == true {
            print("[REQUEST DEPOT]: cancelAllRequests owned by \(owner)")
        }
        currentRequests = Set(currentRequests.filter {$0.owner == owner})
    }
}
