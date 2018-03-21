//
//  CachableRequest.swift
//  Dispatcher-Core-Data
//
//  Created by Rostyslav Stakhiv on 9/13/17.
//  Copyright © 2017 Nick Savula. All rights reserved.
//

import UIKit
import CoreData

protocol Cachable {
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> { get }
}

class CachableRequest: Request, Cachable {
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        get {
            preconditionFailure("This var must be overridden in subclass")
        }
    }
}
