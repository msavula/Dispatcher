//
//  DepotRequestHandler.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class DepotRequestHandler: RequestHandler {
    
    let serialQueues = [
        DispatchQueue(label: "com.hive.serialQueue_01"),
        DispatchQueue(label: "com.hive.serialQueue_02"),
        DispatchQueue(label: "com.hive.serialQueue_03"),
        DispatchQueue(label: "com.hive.serialQueue_04")
    ]
    
    // MARK: globals
    // enclosing defaults structure
    private struct depotDefaults {
        private(set) var logDepotOperations: Bool?
        
        init() {
            let plistPath = Bundle.main.path(forResource: "Dispatcher-info", ofType: "plist")
            if let plist = NSDictionary(contentsOfFile: plistPath!) as? [String: Any] {
                #if DEBUG
                    logDepotOperations = plist["LOG_DEPOT_OPERATIONS"] as? Bool
                #endif
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
        let queue = serialQueues[Int(arc4random_uniform(UInt32(serialQueues.count)))] // get one of our 4 serial queues, all requests will be equally distributed
        queue.async {
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
