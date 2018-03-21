//
//  CacheRequestHandler.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 9/13/17.
//  Copyright © 2017 Nick Savula. All rights reserved.
//

import Foundation
import CoreData

class CacheRequestHandler: RequestHandler {

    override func processRequest(request: Request, error: Error?) {
        
        if let request = request as? CachableRequest,
            let cacheCompletion = request.cacheCompletion {
            let fetchRequest = request.fetchRequest
            
            if let result = DataModel.shared.fetchEntities(request: fetchRequest) as? [NSManagedObject] {
                cacheCompletion(result)
            }
        }
        
        super.processRequest(request: request, error: error)
    }
    
    override func reportRequest(request: Request, error: Error?) {
        
        super.reportRequest(request: request, error: error)
    }
    
    override func cancelAllRequests(owner: ObjectIdentifier) {
        
    }

}
