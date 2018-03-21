//
//  HTTPBinPostRequest.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation
import CoreData

class HTTPBinPostRequest: CachableRequest {
    
    class HTTPBinPostResponse: Response {
        
        private(set) var user: User?
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            if let jsonDictionary = json as? Dictionary<String, Any> {
                user = DataModel.shared.parseUserData(data: jsonDictionary)
            }
        }
    }
    
    override var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        get {
            return User.fetchRequest(id: userId)
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
    
    var userId: Int = 2016
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        request.url = URL(string: "https://httpbin.org/post")
        request.httpMethod = "POST"
        
        let originalString = "https://upload.wikimedia.org/wikipedia/en/7/76/Darth_Vader.jpg"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let payload = ["userId": userId, "name": "John Doe", "birthdate": "10/18/1962", "bio": "long time ago in a galaxy far, far away", "avatar": escapedString] as [String : Any]
        do {
            let postData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = postData
        } catch {
            // TODO: throw error
        }
        
        return request
    }
}
