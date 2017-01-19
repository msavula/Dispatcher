//
//  HTTPBinUtf8Request.swift
//
//  Created by  Nick Savula on 2016-12-16.
//

import Foundation

class HTTPBinUtf8Request: Request {
    
    class HTTPBinUtf8Response: Response {
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            //FIXME: Do object/core data model filling from variable json
        }
    }
    
    private lazy var actualResponse = HTTPBinUtf8Response()
    override private(set) var response: Response {
        get {
            return actualResponse
        }
        set {
            if newValue is HTTPBinUtf8Response {
                actualResponse = newValue as! HTTPBinUtf8Response
            } else {
                print("incorrect type of response")
            }
        }
    }
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        request.url = URL(string: "https://httpbin.org/encoding/utf8")
        
        return request
    }
}

    
