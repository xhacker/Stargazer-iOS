//
//  StarListTableViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-05.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import CoreData
import TagListView

class StarListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var predicate: NSPredicate?
    var searchResults: [Repo] = []
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Repo")
        fetchRequest.predicate = self.predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        searchDisplayController?.searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        searchDisplayController?.searchResultsTableView.estimatedRowHeight = 100
        
        var error: NSError? = nil
        if fetchedResultsController.performFetch(&error) == false {
            print("An error occurred: \(error?.localizedDescription)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchDisplayController?.searchResultsTableView {
            return searchResults.count
        }
        else {
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section] as! NSFetchedResultsSectionInfo
                return currentSection.numberOfObjects
            }
            
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! StarListTableViewCell
        
        let repo: Repo = {
            if tableView == self.searchDisplayController?.searchResultsTableView {
                return self.searchResults[indexPath.row]
            }
            else {
                return self.fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
            }
        }()
        cell.nameLabel.text = repo.name
        cell.languageLabel.text = repo.language
        cell.languageLabel.textColor = UIColor(red: 0.88, green: 0.31, blue: 0.22, alpha: 1)
        cell.starsLabel.text = toString(repo.stargazers_count as? Int ?? 0)
        cell.descriptionLabel.text = repo.desc
        
        cell.tagListView.removeAllTags()
        for tag in repo.tags {
            cell.tagListView.addTag(tag.name)
        }
        
        cell.updateConstraintsIfNeeded()

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
    
    // MARK: - Fetched results controller delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject object: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!)
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            default:
                return
            }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Search bar delegate
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let filter = NSPredicate(format: "name contains[cd] %@ OR desc contains[cd] %@", searchString, searchString)
        let globalPredicate = self.predicate ?? NSPredicate(value: true)
        let compoundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates([globalPredicate, filter])
        let fetchRequest = NSFetchRequest(entityName: "Repo")
        fetchRequest.predicate = compoundPredicate
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Repo] {
            searchResults = fetchResults
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let webViewController = segue.destinationViewController as! StarWebViewController
        
        if searchDisplayController!.active {
            let indexPath = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
            let starItem = searchResults[indexPath.row]
            webViewController.repo = starItem
        }
        else {
            let indexPath = tableView.indexPathForSelectedRow()!
            let starItem = fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
            webViewController.repo = starItem
        }
    }

}
