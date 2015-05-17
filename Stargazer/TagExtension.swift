//
//  TagExtension.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-16.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import CoreData

extension Tag {
    static func returnOrCreate(name: String, inContext context: NSManagedObjectContext) -> Tag {
        let fetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as! [Tag]
        if fetchResults.count > 0 {
            return fetchResults[0]
        }
        else {
            let tag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: context) as! Tag
            tag.name = name
            
            return tag
        }
    }
}