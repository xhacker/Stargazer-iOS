//
//  RepoExtension.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-16.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import CoreData

extension Repo {
    static func createFromDictionary(star: [String: AnyObject], inContext context: NSManagedObjectContext) -> Repo {
        let repo = NSEntityDescription.insertNewObjectForEntityForName("Repo", inManagedObjectContext: context) as! Repo
        repo.id = star["id"] as! Int
        repo.name = star["name"] as! String
        repo.full_name = star["full_name"] as! String
        repo.desc = star["description"] as! String
        repo.html_url = star["html_url"] as! String
        repo.language = star["language"] as! String
        repo.forks_count = star["forks_count"] as! Int
        repo.stargazers_count = star["stargazers_count"] as! Int
        
        return repo
    }
}
