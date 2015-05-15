//
//  Repo.swift
//  
//
//  Created by Dongyuan Liu on 2015-05-15.
//
//

import Foundation
import CoreData

class Repo: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var full_name: String
    @NSManaged var desc: String
    @NSManaged var html_url: String
    @NSManaged var language: String
    @NSManaged var forks_count: NSNumber
    @NSManaged var stargazers_count: NSNumber
    @NSManaged var tags: NSSet

}
