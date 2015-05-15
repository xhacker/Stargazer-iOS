//
//  Tag.swift
//  
//
//  Created by Dongyuan Liu on 2015-05-15.
//
//

import Foundation
import CoreData

class Tag: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var repos: NSSet

}
