//
//  User+CoreDataClass.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    
    func parseNode(node: Dictionary<String, Any>) {
        userId = Int32(node["userId"] as! String)!
        name = node["name"] as? String
        bio = node["bio"] as? String
        avatar = node["avatar"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        birthdate = dateFormatter.date(from: node["birthdate"] as! String) as NSDate?
    }
}
