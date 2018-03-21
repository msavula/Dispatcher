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
public class User: NSManagedObject, ModelMapper {
    
    static var entityName: String {
        get {
            return "User"
        }
    }
    
    static var idKey: String {
        get {
            return "userId"
        }
    }
    
    static func fetchRequest(id: Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(idKey) == \(id)")
        return fetchRequest as! NSFetchRequest<NSFetchRequestResult>
    }
    
    func parse(node: Dictionary<AnyHashable, Any>) {
        userId = Int32(node["userId"] as! Int)
        name = node["name"] as? String
        bio = node["bio"] as? String
        avatar = node["avatar"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        birthdate = dateFormatter.date(from: node["birthdate"] as! String) as NSDate?
    }
}
