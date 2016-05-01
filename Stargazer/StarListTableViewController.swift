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

class StarListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, TagListViewDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var predicate: NSPredicate?
    var searchController: UISearchController!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Repo")
        fetchRequest.predicate = self.predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
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
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .Minimal
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("An error occurred: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! StarListTableViewCell
        
        let repo = fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
        cell.nameLabel.text = repo.name
        cell.languageLabel.text = repo.language
        cell.languageLabel.textColor = UIColor(red: 0.88, green: 0.31, blue: 0.22, alpha: 1)
        cell.starsLabel.text = String(repo.stargazers_count)
        cell.descriptionLabel.text = repo.desc
        
        cell.tagListView.delegate = self
        cell.tagListView.removeAllTags()
        let blueColor = UIColor(red:0.43, green:0.65, blue:0.91, alpha:1)
        if repo.tags.count > 0 {
            cell.tagListView.tagBackgroundColor = blueColor
            cell.tagListView.textColor = UIColor.whiteColor()
            cell.tagListView.borderWidth = 0
            
            for tag in repo.tags {
                cell.tagListView.addTag(tag.name)
            }
        }
        else {
            cell.tagListView.tagBackgroundColor = UIColor.clearColor()
            cell.tagListView.textColor = blueColor
            cell.tagListView.borderColor = blueColor
            cell.tagListView.borderWidth = 1
            
            cell.tagListView.addTag("add tag...")
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
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Search controller delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        let filter = NSPredicate(format: "name contains[cd] %@ OR desc contains[cd] %@", searchString, searchString)
        let globalPredicate = self.predicate ?? NSPredicate(value: true)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [globalPredicate, filter])
        
        if searchString.characters.count > 0 {
            fetchedResultsController.fetchRequest.predicate = compoundPredicate
        }
        else {
            fetchedResultsController.fetchRequest.predicate = self.predicate
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("An error occurred: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Tag list view delegate
    
    func tagPressed(title: String, sender: TagListView) {
        if title == "add tag..." {
            performSegueWithIdentifier("showRepo", sender: sender)
        }
        else {
            let viewController = storyboard?.instantiateViewControllerWithIdentifier("StarList") as! StarListTableViewController
            viewController.title = title
            viewController.predicate = NSPredicate(format: "ANY tags.name == %@", title)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRepoFromCell" {
            let indexPath = tableView.indexPathForSelectedRow!
            let starItem = fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
            let webViewController = segue.destinationViewController as! StarWebViewController
            webViewController.repo = starItem
        }
        else if segue.identifier == "showRepo" {
            let tagListView = sender as! TagListView
            
            // TagListView -> UITableViewCellContentView -> UITableViewCell
            let cell = tagListView.superview?.superview as! UITableViewCell
            
            let indexPath = tableView.indexPathForCell(cell)!
            let starItem = fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
            let webViewController = segue.destinationViewController as! StarWebViewController
            webViewController.repo = starItem
            webViewController.shouldActiveTokenInputView = true
        }
    }

}
