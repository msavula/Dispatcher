//
//  RequestHandler.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class RequestHandler {
    
    var previousHandler: RequestHandler?
    var nextHandler: RequestHandler? {
        didSet {
            // capture previous handler
            nextHandler?.previousHandler = self
        }
    }
    
    
    func processRequest(request: Request, error: Error?) {
        if let handler = nextHandler, !request.completed && !request.canceled && error == nil {
            handler.processRequest(request: request, error: error)
        } else {
            request.completed = true
            reportRequest(request: request, error: error)
        }
    }
    
    // TODO: throws errors
    func reportRequest(request: Request, error: Error?) {
        if request.canceled {
            return
        }
        
        if let handler = self.previousHandler {
            handler.reportRequest(request: request, error: error)
        } else if let closure = request.completion {
            closure(request, error)
        }
    }
    
    func cancelAllRequests(owner: ObjectIdentifier) {
    }
}
