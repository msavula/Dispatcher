//
//  Dispatcher.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class Dispatcher {
    static let shared = Dispatcher()
    private var headRequestHandler = DepotRequestHandler()
    
    private init() {
        let cacheHandler = CacheRequestHandler()
        headRequestHandler.nextHandler = cacheHandler
        cacheHandler.nextHandler = ServiceRequestHandler()
    }
    
    public func processRequest(request: Request) {
        headRequestHandler.processRequest(request: request, error: nil)
    }
    
    public func cancelAllRequests(owner: ObjectIdentifier) {
        headRequestHandler.cancelAllRequests(owner: owner)
    }
}
