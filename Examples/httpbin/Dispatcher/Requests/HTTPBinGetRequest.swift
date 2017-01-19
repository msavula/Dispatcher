//
//  HTTPBinGetRequest.swift
//  Dispatcher
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class HTTPBinGetRequest: Request {
    
    class HTTPBinGetResponse: Response {
        
        private(set) var origin: String?
        private(set) var url: String?
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            if let jsonDictionary = json as? Dictionary<String, Any> {
                origin = jsonDictionary["origin"] as? String
                url = jsonDictionary["url"] as? String
            }
        }
    }
    
    private lazy var httpBinGetResponse = HTTPBinGetResponse()
    override private(set) var response: Response {
        get {
            return httpBinGetResponse
        }
        set {
            if newValue is HTTPBinGetResponse {
                httpBinGetResponse = newValue as! HTTPBinGetResponse
            } else {
                print("incorrect type of response")
            }
        }
    }
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        request.url = URL(string: "https://httpbin.org/get")
        
        return request
    }
}
