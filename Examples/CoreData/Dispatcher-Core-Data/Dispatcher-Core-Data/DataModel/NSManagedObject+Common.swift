//
//  NSManagedObject+Common.swift
//  HiveSocial
//
//  Created by Nick Savula on 12/16/16.
//  Copyright © 2016 KindGeek. All rights reserved.
//

import Foundation
import CoreData

/*
 @discussion
 - perhaps parse func should throw errer, in case required fields are missing?
 - since date formatter is uniform and is used quite often, it makes sense to make it static
    TODO: find a place for static date formatter to reside
 */

protocol ModelMapper {
    
    static var entityName: String {get}
    static var idKey: String {get}
    
    func parse(node: Dictionary<AnyHashable, Any>)
    static func fetchRequest(id: Int) -> NSFetchRequest<NSFetchRequestResult>
    static func fetchRequest(stringId: String) -> NSFetchRequest<NSFetchRequestResult>
}

extension ModelMapper {
    static func fetchRequest(stringId: String) -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
    }
}
