//
//  HTTPBinPostRequest.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation

class HTTPBinPostRequest: Request {
    
    class HTTPBinPostResponse: Response {
        
        private(set) var user: User?
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            if let jsonDictionary = json as? Dictionary<String, Any> {
                user = DataModel.sharedDatabaseStorage.parseUserData(data: jsonDictionary)
            }
        }
    }
    
    private lazy var httpBinPostResponse = HTTPBinPostResponse()
    override private(set) var response: Response {
        get {
            return httpBinPostResponse
        }
        set {
            if newValue is HTTPBinPostResponse {
                httpBinPostResponse = newValue as! HTTPBinPostResponse
            } else {
                print("incorrect type of response")
            }
        }
    }
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        request.url = URL(string: "https://httpbin.org/post")
        request.httpMethod = "POST"
        
        let originalString = "https://upload.wikimedia.org/wikipedia/en/7/76/Darth_Vader.jpg"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        request.httpBody = "userId=2016&name=John Doe&birthdate=10/18/1962&bio=long time ago in a galaxy far, far away&avatar=\(escapedString)".data(using: .utf8)
        
        return request
    }
}
