//
//  StarsTableViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-04-30.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import CoreData

class StarsTableViewController: UITableViewController {
    
    enum Section: Int {
        case Stars = 0
        case Tags
        static let count = 2
        
        var title: String? {
            switch self {
            case .Stars:
                return "Stars"
            case .Tags:
                return "Tags"
            }
        }
    }
    
    // cells in Stars section
    enum StarsCell: Int {
        case All = 0
        case Untagged
        static let count = 2
        
        var title: String? {
            switch self {
            case .All:
                return "All"
            case .Untagged:
                return "Untagged"
            }
        }
    }
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var allRepos: [Repo] = []
    var untaggedRepos: [Repo] = []
    var tags: [Tag] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "coreDataObjectsDidChange", name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .Stars:
            return StarsCell.count
        case .Tags:
            return tags.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        switch Section(rawValue: indexPath.section)! {
        case .Stars:
            cell.textLabel?.text = StarsCell(rawValue: indexPath.row)!.title
            switch StarsCell(rawValue: indexPath.row)! {
            case .All:
                cell.detailTextLabel?.text = String(allRepos.count)
            case .Untagged:
                cell.detailTextLabel?.text = String(untaggedRepos.count)
            }
        case .Tags:
            cell.textLabel?.text = tags[indexPath.row].name
            cell.detailTextLabel?.text = String(tags[indexPath.row].repos.count)
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    // MARK: - Notification
    
    func coreDataObjectsDidChange() {
        reloadData()
        tableView.reloadData()
    }
    
    func reloadData() {
        let tagFetchRequest = NSFetchRequest(entityName: "Tag")
        if let fetchResults = managedObjectContext!.executeFetchRequest(tagFetchRequest, error: nil) as? [Tag] {
            tags = fetchResults
        }
        
        let allReposFetchRequest = NSFetchRequest(entityName: "Repo")
        if let fetchResults = managedObjectContext!.executeFetchRequest(allReposFetchRequest, error: nil) as? [Repo] {
            allRepos = fetchResults
        }
        
        let untaggedReposFetchRequest = NSFetchRequest(entityName: "Repo")
        untaggedReposFetchRequest.predicate = NSPredicate(format: "tags.@count == 0")
        if let fetchResults = managedObjectContext!.executeFetchRequest(untaggedReposFetchRequest, error: nil) as? [Repo] {
            untaggedRepos = fetchResults
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()!
        let viewController = segue.destinationViewController as! StarListTableViewController

        switch Section(rawValue: indexPath.section)! {
        case .Stars:
            switch StarsCell(rawValue: indexPath.row)! {
            case .All:
                viewController.title = "All"
            case .Untagged:
                viewController.title = "Untagged"
                viewController.predicate = NSPredicate(format: "tags.@count == 0")
            }
        case .Tags:
            viewController.title = tags[indexPath.row].name
            viewController.predicate = NSPredicate(format: "ANY tags.name == %@", tags[indexPath.row].name)
        }
    }

}
