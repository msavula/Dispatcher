//
//  User+CoreDataProperties.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var userId: Int32
    @NSManaged public var name: String?
    @NSManaged public var birthdate: NSDate?
    @NSManaged public var bio: String?
    @NSManaged public var avatar: String?

}
