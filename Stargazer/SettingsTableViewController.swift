//
//  SettingsTableViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-04-30.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import KeychainAccess
import CoreData
import Alamofire

class SettingsTableViewController: UITableViewController {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            signOut()
        }
    }
    
    func signOut() {
        let keychain = Keychain(service: kKeychainServiceName)
        keychain[kKeychainGitHubTokenKey] = nil
        Router.OAuthToken = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kUserDefaultsFetchedKey)
        
        // remove all core data items
        println("Removing repos...")
        let repoFetchRequest = NSFetchRequest(entityName: "Repo")
        if let fetchResults = managedObjectContext!.executeFetchRequest(repoFetchRequest, error: nil) as? [Repo] {
            for repo in fetchResults {
                managedObjectContext!.deleteObject(repo)
            }
        }
        
        println("Removing tags...")
        let tagFetchRequest = NSFetchRequest(entityName: "Tag")
        if let fetchResults = managedObjectContext!.executeFetchRequest(tagFetchRequest, error: nil) as? [Tag] {
            for tag in fetchResults {
                managedObjectContext!.deleteObject(tag)
            }
        }
        
        println("Saving...")
        managedObjectContext!.save(nil)
        
        tabBarController?.performSegueWithIdentifier("signIn", sender: self)
    }

}
